class PriceList < ActiveRecord::Base
  
  def self.check_report_price_list(bulan, tahun)
    CheckedItemMaster.where("customer_services = ?", false).each do |uncheck|
      uncheck.destroy
    end
    LaporanCabang.compare_price_list(bulan, tahun).each do |lap|
      unless lap.kodebrg[2].nil?
        merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
        Cabang.find(lap.cabang_id).regional.each do |cabreg|
          PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", 
            merk.first.id, cabreg.id, lap.kodebrg).each do |pricelist|
            customer_services = CheckedItemMaster.where("nofaktur like ? and kodebarang like ? and customer like ? and quantity like ?", lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah)
            if customer_services.empty?
              if (lap.hargasatuan != pricelist.harga) || ((lap.nupgrade*lap.jumlah) != pricelist.upgrade) || 
                  (lap.cashback != pricelist.cashback) || (lap.diskon1 != pricelist.discount_1) || (lap.diskon2 != pricelist.discount_2)
                CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal, 
                  :kodebarang => lap.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
                  :harga_master => pricelist.harga, :harga_laporan => lap.hargasatuan,
                  :upgrade_master => pricelist.upgrade, :upgrade_laporan => lap.nupgrade,
                  :panjang => lap.panjang, :lebar => lap.lebar,
                  :quantity => lap.jumlah, :checked => false,
                  :cashback_master => pricelist.cashback, :cashback_laporan => lap.cashback,
                  :discount_1_master => pricelist.discount_1, :discount_1_laporan => lap.diskon1,
                  :discount_2_master => pricelist.discount_2, :discount_2_laporan => lap.diskon2,
                  :customer => lap.customer)
              end
            end
          end
        end
      end
    end
  end
end
