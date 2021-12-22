class SalesWarehouse < ActiveRecord::Base
  establish_connection "sales-foam"
  set_table_name "sales_warehouses"
  attr_accessible *column_names
end
