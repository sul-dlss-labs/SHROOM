# frozen_string_literal: true

# Controller for Uploaded files
class FilesController < ApplicationController
  def create
    work_file = WorkFile.create!(file_params)
    redirect_to new_works_path(work_file:, doi: params[:doi], preprint: params[:preprint])
  end

  private

  def file_params
    params.permit(:file)
  end
end
