class JdeItemMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4101"
end
