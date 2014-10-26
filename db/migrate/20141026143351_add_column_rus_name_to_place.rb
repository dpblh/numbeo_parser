class AddColumnRusNameToPlace < ActiveRecord::Migration
  def change
    add_column :places, :rus_name, :string
  end
end
