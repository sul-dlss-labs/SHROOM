# frozen_string_literal: true

# Controller for Uploaded files
class FilesController < ApplicationController
  def new; end

  def create
    work_file = WorkFile.create!(file_params)
    redirect_to new_work_path(work_file:)
  end

  private

  def file_params
    params.permit(:file)
  end
end
