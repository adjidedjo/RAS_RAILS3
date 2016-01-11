class JdeEnterDraft < ActiveRecord::Base
  establish_connection "jdeoracle"
#  self.abstract_class = true
  self.table_name = "proddta.f03b13"
end
