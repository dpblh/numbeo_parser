class AddIndexes < ActiveRecord::Migration
  def change
    add_index :cities, :name
    add_index :cities, :rus_name

    add_index :countries, :name
    add_index :countries, :rus_name

    add_index :places, :name
    add_index :places, :rus_name
    add_index :places, :price
    add_index :places, :city_id
    add_index :places, :currency_id
    add_index :places, :category_id
    add_index :places, :translate

    add_index :currencies, :name
    add_index :currencies, :rate

    add_index :categories, :name
  end
end
