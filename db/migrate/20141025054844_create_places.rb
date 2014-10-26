class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :price
      t.belongs_to :city
      t.references :currency
      t.references :category

      t.timestamps
    end
  end
end
