class DailySale < ActiveRecord::Base
  
  validates :brand, presence: true, numericality: { only_integer: true }
  
  def self.daily_sales_report
    day = "day" + Date.today.strftime('%d')
    Cabang.all.each do |cabang|
      ['ELITE', 'LADY', 'ROYAL','SERENITY'].each do |brand|
      LaporanCabang.find_by_sql(
        "SELECT tanggalsj, jenisbrgdisc, sum(jumlah) as total FROM tblaporancabang WHERE cabang_id = '#{cabang.id}' 
        AND jenisbrgdisc like '#{brand}' AND tanggalsj = '#{Date.today.to_date}' AND kodejenis like 'KM'
        GROUP BY tanggalsj, jenisbrgdisc, cabang_id").each do |lc|
          DailySale.create(bulan: lc.tanggalsj.to_date.month, tahun: lc.tanggalsj.to_date.year, 
          brand: Merk.find_by_jde_brand(lc.jenisbrgdisc).id, cabang_id: cabang.id, tipe: 'Penjualan',
          day.to_sym => lc.total)
        end
      end
    end
  end
end