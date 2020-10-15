class JdeInvoiceProcessing < ActiveRecord::Base
  establish_connection "jdeoracle"
#  self.abstract_class = true
  self.table_name = "PRODDTA.F03B11"
  
  def self.insert_pos_to_jde(pos)
    connection.execute("
      INSERT INTO PRODDTA.F55ADD1(ECVR01, ECC75PNAME, ECCF01, ECPH1, ECTX2) 
      VALUES ('#{pos.map{|x| x.inspect}.join(', ')}}'')
    ")
  end
  
  def self.credit_memo
    cm = self.find_by_sql("SELECT rpdivj, rpag, rpsdoc,rprmk FROM PRODDTA.F03B11 WHERE rpdivj = '#{date_to_julian('16/02/2017'.to_date)}'")
    cm.each do |memo|
      report = self.find_by_sql("UPDATE harganetto1 = '#{memo.rpag.to_i}' WHERE noso = '#{memo.rpsdoc.strip}' AND
      kodebrg = '#{memo.rprmk.strip}' LIMIT 1")
    end
  end

  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

end
