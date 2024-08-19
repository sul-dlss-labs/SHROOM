# frozen_string_literal: true

# Controller for Works
class WorksController < ApplicationController
  before_action :find_work, only: %i[show edit edit_button update]
  before_action :find_cocina_object, only: %i[show edit update]
  def index
    @works = Work.order(id: :desc).page(params[:page])
  end

  def show; end

  def new
    @work_form = build_new_work_form
  end

  def edit
    @work_form = WorkCocinaMapperService.to_work(cocina_object: @cocina_object)
  rescue WorkCocinaMapperService::UnmappableError
    render :unmappable, status: :unprocessable_entity
  end

  def create
    @work_form = WorkForm.new(work_params)
    if @work_form.valid?
      cocina_object = WorkCocinaMapperService.to_cocina(work_form: @work_form)
      @work = Work.create!(title: @work_form.title)
      work_file.update!(work: @work)

      Sdr::DepositService.call(work: @work, cocina_object:)

      redirect_to @work
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit_button
    return render :edit_button, layout: false if Sdr::VersionService.openable?(druid: @work.druid)

    head :no_content
  end

  def update
    @work_form = WorkForm.new(work_params)
    if @work_form.valid?
      new_cocina_object = WorkCocinaMapperService.to_cocina(work_form: @work_form,
                                                            druid: @work.druid,
                                                            version: @cocina_object.version + 1,
                                                            source_id: @cocina_object.identification.sourceId)

      Sdr::UpdateService.call(cocina_object: new_cocina_object, existing_cocina_object: @cocina_object, work: @work)
      @work.update!(title: @work_form.title)

      redirect_to @work
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def build_new_work_form
    return WorkForm.new unless params.key?(:work_file)

    GrobidService.call(path: work_file.path)
  end

  def work_params
    # Perhaps these can be introspected from the model?
    params.require(:work).permit(
      :title, :abstract, :publisher,
      :published_year, :published_month, :published_day,
      authors_attributes: [
        :first_name, :last_name, { affiliations_attributes: %i[organization department] }
      ],
      keywords_attributes: %i[value]
    )
  end

  def work_file
    @work_file ||= WorkFile.find(work_file_param)
  end

  def work_file_param
    @work_file_param ||= params[:work_file] || params[:work][:work_file]
  end

  def find_work
    @work = Work.find(params[:id])
  end

  def find_cocina_object
    @cocina_object = Sdr::Repository.find(druid: @work.druid)
  end
end
