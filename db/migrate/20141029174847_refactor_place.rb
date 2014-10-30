class RefactorPlace < ActiveRecord::Migration
  def change
    remove_column :places, :price
    remove_column :places, :city_id
    remove_column :places, :currency_id
  end
end
