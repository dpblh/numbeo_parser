class CreatePlacePositions < ActiveRecord::Migration
  def change
    create_table :place_positions do |t|
      t.string :price
      t.belongs_to :city
      t.belongs_to :place
      t.belongs_to :currency

      t.timestamps
    end

    add_index :place_positions, :price
    add_index :place_positions, :city_id
    add_index :place_positions, :place_id
    add_index :place_positions, :currency_id

  end
end
