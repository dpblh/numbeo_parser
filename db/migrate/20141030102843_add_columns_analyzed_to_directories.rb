class AddColumnsAnalyzedToDirectories < ActiveRecord::Migration
  def change
    add_column :cities, :analyzed, :boolean, default: false
    add_column :countries, :analyzed, :boolean, default: false
  end
end
