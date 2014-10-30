class AddColumnsTranslate < ActiveRecord::Migration
  def change
    add_column :cities, :translate, :boolean, default: false
    add_column :countries, :translate, :boolean, default: false
    add_column :categories, :translate, :boolean, default: false
  end
end
