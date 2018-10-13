class Warehouse::F41021Stock < ActiveRecord::Base
  establish_connection "warehouse"
  self.table_name = "F41021_STOCK" #rp
  
  def self.import_stock_warehouse
    ActiveRecord::Base.establish_connection("warehouse").connection.execute("
      DELETE FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{14.days.ago.to_date}'
    ")
    stocks = ActiveRecord::Base.establish_connection("jdeoracle").connection.execute("
      SELECT LIITM, LIMCU, LIPQOH, LILOTN, LIGLPT, LILRCJ, LIHCOM FROM PRODDTA.F41021 WHERE
      LIPQOH >= 10000 AND LIPBIN = 'S'")
    while r = stocks.fetch_hash
      item_master = JdeItemMaster.get_item_number(r["LIITM"]).first
      fullnamabarang = item_master.imdsc1.strip + " " + item_master.imdsc2.strip
      self.create(short_item: r["LIITM"].to_i, item_number: item_master.imlitm.strip, brand: item_master.imprgr.strip,
        description: fullnamabarang, branch: r["LIMCU"].strip, onhand: r["LIPQOH"]/10000, 
        hardcommit: r["LIHCOM"]/10000, glcat: r["LIGLPT"], serial: r["LILOTN"].strip, 
        receipt_date: JdeInvoice.julian_to_date(r["LILRCJ"]))
    end
    JdeItemAvailability.historical_stock
  end
end