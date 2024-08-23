class CreateCollection < ActiveRecord::Migration[7.2]
  def change
    create_table :collections do |t|
      t.string :druid, index: { unique: true }
      t.string :title, null: false
      t.timestamps
    end
  end
end
