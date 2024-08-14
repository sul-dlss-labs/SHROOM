# frozen_string_literal: true

# Controller for Works
class WorksController < ApplicationController
  def new
    @work = build_new_work
    Rails.logger.info("Work: #{@work.to_json}")
  end

  def create
    # This is just for demo purposes.
    # Don't forget to remove create.html.erb and remove data-turbo=false from new.html.erb.
    @work = WorkForm.new(work_params)
    return render :new, status: :unprocessable_entity unless @work.valid?

    Rails.logger.info("Work: #{@work.to_json}")
    @cocina_object = WorkCocinaMapperService.to_cocina(work: @work)

    FileStore.delete(key: file_key_param) if file_key_param.present?

    render :create
  end

  private

  def build_new_work
    return WorkForm.new unless params.key?(:file_key)

    GrobidService.call(path: ActiveStorage::Blob.service.path_for(file_key_param))
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

  def file_key_param
    @file_key_param ||= params[:file_key]
  end
end
