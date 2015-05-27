class Forecast < ActiveRecord::Base

  scope :cabang, lambda {|cab| where(cabang_id: cab) if cab.present?}
  scope :bulan, lambda {|bul| where(bulan: bul) if bul.present?}
  scope :tahun, lambda {|tah| where(tahun: tah) if tah.present?}

  def self.search_sales(kode_forecast, bulan, tahun, cabang)
    get_kode_barang = GroupForecast.where(kode_barang: kode_forecast)
    if get_kode_barang.blank?
      return 0
    else
      get_kode_barang.each do |item_forecast|
        return LaporanCabang.where("month(tanggalsj) = ? and year(tanggalsj) = ? and cabang_id = ? and kodebrg like ?",
          bulan, tahun, cabang, item_forecast.kode_forecast).sum(:jumlah)
      end
    end
  end
end
