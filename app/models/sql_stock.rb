class SqlStock < ActiveRecord::Base
  # self.abstract_class = true
  # establish_connection "sqlserver"
  # set_table_name "tbStockHarian"
# 
  # def self.stock_mail_sql(cabang, date)
    # select("*").where("Tanggal = ? and Cabang = ?", date, cabang).limit(1)
  # end
end
