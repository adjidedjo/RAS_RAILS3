class JdeInvoiceProcessing < ActiveRecord::Base
  establish_connection "jdeoracle"
#  self.abstract_class = true
  self.table_name = "proddta.f03b11"
end
