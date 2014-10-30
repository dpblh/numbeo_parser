class AddColumnCountryToPlacePosition < ActiveRecord::Migration
  def change
    add_column :place_positions, :country_id, :integer

    add_index :place_positions, :country_id
  end
end
