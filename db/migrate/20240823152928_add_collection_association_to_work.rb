class AddCollectionAssociationToWork < ActiveRecord::Migration[7.2]
  def change
    add_reference :works, :collection, foreign_key: true
  end
end
