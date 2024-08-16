class AddWorkAssociationToWorkFile < ActiveRecord::Migration[7.2]
  def change
    add_reference :work_files, :work, foreign_key: true
  end
end
