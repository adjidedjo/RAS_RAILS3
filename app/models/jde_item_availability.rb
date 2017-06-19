class JdeItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f41021" #sd
  # attr_accessible :lilotn, :lilrcj
  # self.primary_key = 'lilotn'
  

  def self.available
    where("limcu like ? and lipqoh >= ?", "%11011", 1)
  end
  
  def self.stock_periods
    find_by_sql("SELECT * FROM PRODDTA.F41021 WHERE lilotn > 1 AND 
    limcu LIKE '%#{11011}' AND lipqoh >= 1 GROUP BY ")
  end
  
  def self.update_last_receipt(serial, branch, date)
    a = find_by_sql("SELECT * FROM PRODDTA.F41021 WHERE lilotn LIKE '%#{serial}%' AND 
    limcu LIKE '%#{branch}'").first
    unless a.nil?
      # a.lilrcj = date
      # a.save!
      a.update_attributes!(lilrcj: date)
      CsYearBarcode.find_by_barcode(serial).update_attributes!(updated: true)
    end
  end
  
  def self.find_last_receipt
    serialized = find_by_sql("SELECT liitm, limcu, lilotn, liglpt, lilrcj  FROM PRODDTA.F41021 
    WHERE lipqoh >= 1")
    serialized.each do |sr|
      find_serial = PeriodSerialStock.find_by_serial_and_branch(sr.lilotn, limcu)
      if find_serial.present?
        find_serial.update_attributes!(onhand: sr.lipqoh)
      else
        date_receipt = julian_to_date(lilrcj)
        PerioSerialStock.create!(short_item_no: sr.liitm, serial: sr.lilotn, product: sr.liglpt,
        branch: sr.limcu, last_receipt_date: date_receipt, last_receipt_day: date_receipt.day,
        last_receipt_month: date_receipt.month, last_receipt_year: date_receipt_year,
        last_updated_at: Date.today)
      end
    end
  end
  
  private
  
  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
end
