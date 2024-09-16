class CreateGeonames < ActiveRecord::Migration[7.2]
  def change
    create_table :geonames do |t|
      t.string :name, null: false
      t.index :name, unique: true
    end
  end
end
