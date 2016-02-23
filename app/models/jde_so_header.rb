class JdeSoHeader < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4201"
end
