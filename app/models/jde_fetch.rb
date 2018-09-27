class JdeFetch < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4211" #sd
  
  def self.checking_buffer
    Stock.all.each do |stock|
      buffer_jde = self.find_by_sql("SELECT ibsafe FROM PRODDTA.F4102 WHERE 
      iblitm LIKE '%#{stock.item_number}%' AND ibmcu LIKE '%#{stock.branch}%'")
      unless buffer_jde.empty?
        if stock.buffer != (buffer_jde.first.ibsafe/10000)
          stock.update_attributes!(buffer: (buffer_jde.first.ibsafe/10000))
        end
      end
    end
  end
  
  def self.checking_item_cost
    Stock.all.each do |stock|
      item_cost_jde = self.find_by_sql("SELECT councs FROM PRODDTA.F4105 WHERE coledg LIKE '%07%' AND 
      colitm LIKE '%#{stock.item_number}%' AND comcu LIKE '%#{stock.branch}%'")
      unless item_cost_jde.empty?
        if stock.item_cost != (item_cost_jde.first.councs/10000)
          stock.update_attributes!(item_cost: (item_cost_jde.first.councs/10000))
        end
      end
    end
  end
  
  def self.update_salesman
    LaporanCabang.where("fiscal_month = 4 and fiscal_year = 2017 and cabang_id = 8").each do |lc|
      unless lc.jenisbrgdisc.nil?
      sales_id = JdeSalesman.find_salesman_id(lc.kode_customer, lc.jenisbrgdisc[0])
      sales = JdeSalesman.find_salesman(lc.kode_customer, lc.jenisbrgdisc[0])
      lc.update_attributes!(nopo: sales_id, salesman: sales)
      end
    end
  end
end