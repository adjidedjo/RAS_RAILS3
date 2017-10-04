class Pdc::ProductionStock < ActiveRecord::Base
  establish_connection "production-analysis"
  self.table_name = "stocks" #sd
end