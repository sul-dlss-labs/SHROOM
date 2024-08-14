# frozen_string_literal: true

# Controller for Uploaded files
class FilesController < ApplicationController
  def new; end

  def create
    key = FileStore.store(path: params[:file].to_path)
    redirect_to new_work_path(file_key: key)
  end
end
