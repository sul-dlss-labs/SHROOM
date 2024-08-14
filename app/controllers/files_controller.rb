# frozen_string_literal: true

# Controller for Uploaded files
class FilesController < ApplicationController
  def new; end

  def create
    work_file = WorkFile.create!(file_params)
    redirect_to new_work_path(file_key: blob_for_file(work_file.id).key)
  end

  private

  def file_params
    # debugger
    params.permit(:file)
  end

  def blob_for_file(file_id)
    ActiveStorage::Blob.find(file_id)
  end
end
