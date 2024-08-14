class CreateWorkFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :work_files do |t|

      t.timestamps
    end
  end
end
