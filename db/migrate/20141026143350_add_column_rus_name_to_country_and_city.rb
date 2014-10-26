class AddColumnRusNameToCountryAndCity < ActiveRecord::Migration
  def change
    add_column :countries, :rus_name, :string
    add_column :cities, :rus_name, :string
  end
end
