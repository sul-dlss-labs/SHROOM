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
    @cocina_object = WorkCocinaMapperService.to_cocina(work: work)

    Rails.logger.info("CREATE!!!!")

    render :create
  end

  private

  def build_new_work
    return Work.new unless params.key?(:file)

    GrobidService.call(path: params[:file].to_path)
  end

  def work_params
    params.require(:work).permit(:title)
  end
end
