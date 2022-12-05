class SalesOrderHistoryJde < ActiveRecord::Base
  #KHUSUS UNTUK PENERIMAAN BARANG POS
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4211" #sd

  scope :delivered, -> { where("sdnxtr >= ? and sdlttr >= ? and regexp_like(sddcto, ?)", "580", "565", 'SK|ST') }

  def self.find_sales_transfer_to_showroom(date, date_to, showroom_id)
    find_by_sql("SELECT SDMCU, SDDOCO, SDADDJ, SDLITM, SDDSC1, SDDSC2, SDLOTN, SDDELN, SDSOQS FROM PRODDTA.F4211
 		WHERE SDNXTR >= 580 AND SDLTTR >= 565 AND REGEXP_LIKE(SDDCTO, 'SK|ST') 
    		AND SDADDJ BETWEEN '#{date_to_julian(date)}' AND '#{date_to_julian(date_to)}' AND SDSHAN LIKE '#{showroom_id}' 
		GROUP BY SDMCU, SDDOCO, SDADDJ, SDLITM, SDDSC1, SDDSC2, SDLOTN, SDDELN, SDSOQS")
  end

  def self.date_to_julian(date)
    date = date.to_date
    1000*(date.year-1900)+date.yday
  end
end
