class AddColumnToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :rus_name, :string
  end
end
