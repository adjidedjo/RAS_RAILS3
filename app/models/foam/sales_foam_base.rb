class Foam::SalesFoamBase < ActiveRecord::Base
  establish_connection "sales-foam"
  self.table_name = "sales_warehouse" #rp
end