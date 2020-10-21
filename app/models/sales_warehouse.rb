class SalesWarehouse < ActiveRecord::Base
  establish_connection "sales-foam"
  attr_accessible *column_names
end