class AddColumnSalesStockToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sales_stock, :string
  end
end
