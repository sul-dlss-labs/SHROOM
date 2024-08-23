# frozen_string_literal: true

# Controller for Works
class WorksController < ApplicationController
  before_action :find_work, only: %i[show edit edit_button update]
  before_action :find_cocina_object, only: %i[show edit update]
  before_action :find_collections, only: %i[new edit create update index]
  def index
    @works = Work.order(id: :desc).page(params[:page])
    return if params[:collection_druid].blank?

    @works = @works.where(collection: Collection.find_by(druid: params[:collection_druid]))
  end

  def show; end

  def new
    @work_form = build_new_work_form
  end

  def edit
    @work_form = WorkCocinaMapperService.to_work(cocina_object: @cocina_object)
    @work_file = @work.work_files.first
  rescue WorkCocinaMapperService::UnmappableError
    render :unmappable, status: :unprocessable_entity
  end

  def create
    @work_form = WorkForm.new(work_params)
    if @work_form.valid?
      @work = Work.create!(title: @work_form.title, collection: Collection.find_by(druid: @work_form.collection_druid))
      work_file.update!(work: @work)
      cocina_object = WorkCocinaMapperService.to_cocina(work_form: @work_form, source_id: "shroom:object-#{@work.id}")

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
      @work.update!(title: @work_form.title, collection: Collection.find_by(druid: @work_form.collection_druid))

      redirect_to @work
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def grobid_service
    @grobid_service ||= GrobidService.new
  end

  # rubocop:disable Metrics/AbcSize
  def build_new_work_form
    if params[:doi].present?
      grobid_service.from_doi(doi: params[:doi], preprint: preprint?)
    elsif params.key?(:work_file)
      grobid_service.from_file(path: work_file.path, preprint: preprint?)
    else
      WorkForm.new(preprint: preprint?)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def preprint?
    params[:preprint] == 'true'
  end

  def work_params
    # Perhaps these can be introspected from the model?
    params.require(:work).permit(
      :title, :abstract, :publisher,
      :published_year, :published_month, :published_day,
      :related_resource_citation, :preprint, :collection_druid,
      authors_attributes: [
        :first_name, :last_name, :orcid, { affiliations_attributes: %i[organization department] }
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

  def find_collections
    @collections = Collection.all
  end
end
