class AddColumnCodeToCurrency < ActiveRecord::Migration
  def change
    # код некая константа которая всегда должна быть не меняема
    # Пример. Руболь будет всегда с кодом 1. это надо учесть при пересоздании значений в таблице
    add_column :currencies, :code, :integer, unique: true
    add_index :currencies, :code
  end
end
