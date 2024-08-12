class WorksController < ApplicationController
  def new_file
  end

  def new
    # if params[:file]
    @work = build_new_work
  end

  private

  def build_new_work
    return Work.new unless params.key?(:file)

    GrobidService.call(path: params[:file].to_path)
  end
end
