class ChangeColumnTypeForPlacePosition < ActiveRecord::Migration
  def change
    change_column :place_positions, :price, :float
  end
end
