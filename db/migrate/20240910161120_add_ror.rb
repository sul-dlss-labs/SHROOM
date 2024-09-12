class AddRor < ActiveRecord::Migration[7.2]
  def change
    enable_extension "vector"

    create_table :rors do |t|
      t.string :ror_id, null: false
      t.string :label, null: false
      t.string :location
      t.sparsevec :embedding, limit: 30522
      t.timestamps
      t.index :ror_id, unique: true
    end
  end
end
