# frozen_string_literal: true

# Controller for Works
class WorksController < ApplicationController
  before_action :find_work, only: %i[show edit_button]
  before_action :find_work_and_work_file, only: %i[edit update]
  before_action :find_cocina_object_and_sync, only: %i[show edit update]
  before_action :find_collections, only: %i[new edit create update index]
  before_action :find_work_file, only: %i[new create]
  def index
    @works = Work.order(id: :desc).page(params[:page])
    return if params[:collection_druid].blank?

    @works = @works.where(collection: Collection.find_by(druid: params[:collection_druid]))
  end

  def show; end

  def new
    @work_form = build_new_work_form(work_file: @work_file)
  rescue MetadataExtractionService::Error => e
    Honeybadger.notify(e)
    redirect_to works_path, alert: 'Sorry! Unable to process the PDF.'
  end

  def edit
    @work_form = WorkCocinaMapperService.to_work(cocina_object: @cocina_object)
  rescue WorkCocinaMapperService::UnmappableError
    render :unmappable, status: :unprocessable_entity
  end

  def create
    @work_form = WorkForm.new(work_params)
    if @work_form.valid?
      @work = Work.create!(title: @work_form.title, collection: Collection.find_by(druid: @work_form.collection_druid))
      @work_file.update!(work: @work)
      cocina_object = WorkCocinaMapperService.to_cocina(work_form: @work_form, source_id: "shroom:object-#{@work.id}")

      Sdr::DepositService.call(work: @work, cocina_object:)

      redirect_to @work
    else
      flash.now[:error] = 'Validation failed. See below for details.'
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
      WorkSyncService.call(work: @work, cocina_object: new_cocina_object)

      redirect_to @work
    else
      flash.now[:error] = 'Validation failed. See below for details.'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def metadata_extraction_service
    @metadata_extraction_service ||= MetadataExtractionService.new
  end

  # rubocop:disable Metrics/AbcSize
  def build_new_work_form(work_file:)
    if params[:citation].present?
      metadata_extraction_service.from_citation(citation: params[:citation], published: published?)
    elsif params[:doi].present?
      metadata_extraction_service.from_citation(citation: params[:doi], published: published?)
    elsif params.key?(:work_file)
      metadata_extraction_service.from_file(path: work_file.path, published: published?)
    else
      WorkForm.new(published: published?)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def published?
    params[:published] == 'true'
  end

  def work_params
    # Perhaps these can be introspected from the model?
    params.require(:work).permit(
      :title, :abstract, :publisher,
      :related_resource_citation, :published, :collection_druid,
      :related_resource_doi,
      authors_attributes: [
        :first_name, :last_name, { affiliations_attributes: %i[organization] }
      ],
      keywords_attributes: %i[value]
    )
  end

  def find_work_file
    @work_file = work_file_param ? WorkFile.find(work_file_param) : nil
  end

  def find_work_and_work_file
    find_work
    @work_file = @work.work_files.first
  end

  def work_file_param
    @work_file_param ||= params[:work_file] || params.dig(:work, :work_file)
  end

  def find_work
    @work = Work.find(params[:id])
  end

  def find_cocina_object_and_sync
    @cocina_object = Sdr::Repository.find(druid: @work.druid)
    WorkSyncService.call(work: @work, cocina_object: @cocina_object)
  end

  def find_collections
    @collections = Collection.all
  end
end
