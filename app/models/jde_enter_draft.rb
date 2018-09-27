class JdeEnterDraft < ActiveRecord::Base
  establish_connection "jdeoracle"
#  self.abstract_class = true
  self.table_name = "PRODDTA.F03B13"
end
