class Pdc::ProductionStock < ActiveRecord::Base
  establish_connection "production_analysis"
  self.table_name = "stocks" #sd
end