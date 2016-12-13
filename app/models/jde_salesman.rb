class JdeSalesman < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f40344" #sa
  
  
  def self.find_salesman(customer_id, brand)
    commision_table = find_by_sql("SELECT saslsm FROM proddta.f40344 WHERE saan8 like '%#{customer_id}%' AND sait44 like '#{brand}%'")
    salesman_name = commision_table.present? ? JdeCustomerMaster.find_salesman_name(commision_table.first.saslsm.to_i) : '-'
    return salesman_name
  end
end