class Pdc::ProductionStock < ActiveRecord::Base
  establish_connection "production"
  self.table_name = "stocks" #sd
end