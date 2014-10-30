class PriceList < ActiveRecord::Base
  
  def self.check_availability_master(bulan_lalu, bulan, tahun_lalu, tahun)
    LaporanCabang.compare_price_list(bulan_lalu, bulan, tahun_lalu, tahun).each do |lap|
      merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
      unless merk.empty?
        regional = Cabang.find(lap.cabang_id).regional.find_by_brand_id(merk.first.id)
        unless regional.nil?
          price_list = PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", merk.first.id, regional.id, lap.kodebrg)
          future_price_list = FuturePriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", merk.first.id, regional.id, lap.kodebrg)
          if price_list.empty?
            PriceList.create(:cabang_id => lap.cabang_id, :brand_id => merk.first.id, :regional_id => regional.id,
              :jenis => lap.kodejenis, :produk => lap.kodeartikel, :kain => lap.kodekain,
              :panjang => lap.panjang, :lebar => lap.lebar, :harga => 11111, 
              :kode_barang => lap.kodebrg, :nama => lap.namabrg)
          end
          if future_price_list.empty?
            FuturePriceList.create(:cabang_id => lap.cabang_id, :brand_id => merk.first.id, :regional_id => regional.id,
              :jenis => lap.kodejenis, :produk => lap.kodeartikel, :kain => lap.kodekain,
              :panjang => lap.panjang, :lebar => lap.lebar, :harga => 11111,
              :kode_barang => lap.kodebrg, :nama => lap.namabrg)
          end
        end
      end
    end
  end
  
  
  def self.check_report_price_list(bulan_lalu, bulan, tahun_lalu, tahun)
    CheckedItemMaster.where("customer_services = ?", false).each do |uncheck|
      uncheck.destroy
    end
    LaporanCabang.compare_price_list(bulan_lalu, bulan, tahun_lalu, tahun).each do |lap|
      unless lap.kodebrg[2].nil?
        merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
        unless merk.empty?
          Cabang.find(lap.cabang_id).regional.each do |cabreg|
            PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", 
              merk.first.id, cabreg.id, lap.kodebrg).each do |pricelist|
              customer_services = CheckedItemMaster.where("tanggal = ? and nofaktur like ? and kodebarang like ? and customer like ? and quantity like ?", 
                lap.tanggalsj, lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah)
              if customer_services.empty?
                if lap.tanggalsj.month == Date.today.month
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
                      :customer => lap.customer, :tanggal => lap.tanggalsj)
                  end
                else
                  if (lap.hargasatuan != pricelist.prev_harga) || ((lap.nupgrade*lap.jumlah) != pricelist.prev_upgrade) || 
                      (lap.cashback != pricelist.prev_cashback) || (lap.diskon1 != pricelist.prev_discount_1) || (lap.diskon2 != pricelist.prev_discount_2)
                    CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal, 
                      :kodebarang => lap.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
                      :harga_master => pricelist.prev_harga, :harga_laporan => lap.hargasatuan,
                      :upgrade_master => pricelist.prev_upgrade, :upgrade_laporan => lap.nupgrade,
                      :panjang => lap.panjang, :lebar => lap.lebar,
                      :quantity => lap.jumlah, :checked => false,
                      :cashback_master => pricelist.prev_cashback, :cashback_laporan => lap.cashback,
                      :discount_1_master => pricelist.prev_discount_1, :discount_1_laporan => lap.diskon1,
                      :discount_2_master => pricelist.prev_discount_2, :discount_2_laporan => lap.diskon2,
                      :customer => lap.customer, :tanggal => lap.tanggalsj)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end