class WorksController < ApplicationController
  def new_file
  end

  def new
    @work = build_new_work
  end

  def create
    # This is just for demo purposes.
    # Don't forget to remove create.html.erb and remove data-turbo=false from new.html.erb.
    work = Work.new(work_params)
    # TODO: work.validate
    Rails.logger.info("Work: #{work.inspect}")
    @cocina_object = WorkCocinaMapperService.to_cocina(work: work)

    render :create
  end

  private

  def build_new_work
    return Work.new unless params.key?(:file)

    GrobidService.call(path: params[:file].to_path)
  end

  def work_params
    # Perhaps these can be introspected from the model?
    params.require(:work).permit(
      :title,
      authors_attributes: [ :first_name, :last_name ]
    )
  end
end
