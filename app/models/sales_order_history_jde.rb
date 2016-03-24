class SalesOrderHistoryJde < ActiveRecord::Base
  #KHUSUS UNTUK PENERIMAAN BARANG POS
  establish_connection "jdeoracle"
  self.table_name = "proddta.f42119" #sd

  scope :delivered, -> { where("sdnxtr like ? and sdlttr like ? and sddcto like ?", "999", "580", "ST") }

  def self.find_sales_transfer_to_showroom(date, showroom_id)
    where("sdaddj = ? and sdshan like ?", date_to_julian(date), showroom_id).delivered
  end

  def self.date_to_julian(date)
    date = date.to_date
    1000*(date.year-1900)+date.yday
  end
end
