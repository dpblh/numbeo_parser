class AddColumnFromPlace < ActiveRecord::Migration
  def change
    add_column :places, :translate, :boolean, default: false
  end
end
