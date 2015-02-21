class PriceList < ActiveRecord::Base

  has_many :parent_items,  :foreign_key => 'parent_item_id',
    :class_name => 'GoodsHeritage',
    :dependent => :destroy
  has_many :child_items,     :through => :parent_items
  has_many :escapes,   :foreign_key => 'child_item_id',
    :class_name => 'GoodsHeritage',
    :dependent => :destroy
  has_many :predators, :through => :escapes

  def self.check_availability_master(bulan, tahun)
    LaporanCabang.compare_price_list(bulan, tahun).each do |lap|
      merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
      unless merk.empty?
        regional = Cabang.find(lap.cabang_id).regional.find_by_brand_id(merk.first.id)
        unless regional.nil?
          price_list = PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", merk.first.id, regional.id, lap.kodebrg)
          future_price_list = FuturePriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", merk.first.id, regional.id, lap.kodebrg)
          if price_list.empty?
            PriceList.create(:cabang_id => lap.cabang_id, :brand_id => merk.first.id, :regional_id => regional.id,
              :jenis => lap.kodejenis, :produk => lap.kodeartikel, :kain => lap.kodekain,
              :panjang => lap.panjang, :lebar => lap.lebar, :harga => 11111, :prev_harga => 11111,
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


  def self.check_report_price_list(bulan, tahun)
    #    CheckedItemMaster.destroy_all(customer_services: false)
    LaporanCabang.compare_price_list(bulan, tahun).each do |lap|
      unless lap.kodebrg[2].nil?
        merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
        unless merk.empty?
          Cabang.find(lap.cabang_id).regional.each do |cabreg|
            PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?",
              merk.first.id, cabreg.id, lap.kodebrg).each do |pricelist|
              customer_services = CheckedItemMaster.where("tanggal = ? and nofaktur like ? and kodebarang like ? and customer like ? and quantity like ?",
                lap.tanggalsj, lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah)
              if customer_services.empty?
                if lap.tanggalsj.month == bulan
                  if (lap.hargasatuan != pricelist.harga) || ((lap.nupgrade*lap.jumlah) != pricelist.upgrade) ||
                      (lap.cashback != pricelist.cashback) || (lap.diskon1 != pricelist.discount_1) ||
                      (lap.diskon2 != pricelist.discount_2) || (lap.diskon3 != pricelist.discount_3) ||
                      (lap.diskon4 != pricelist.prev_discount_4)
                    CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal,
                      :kodebarang => lap.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
                      :harga_master => pricelist.harga, :harga_laporan => lap.hargasatuan,
                      :upgrade_master => pricelist.upgrade, :upgrade_laporan => lap.nupgrade,
                      :panjang => lap.panjang, :lebar => lap.lebar,
                      :quantity => lap.jumlah, :checked => false, :bonus => lap.bonus,
                      :cashback_master => pricelist.cashback, :cashback_laporan => lap.cashback,
                      :discount_1_master => pricelist.discount_1, :discount_1_laporan => lap.diskon1,
                      :discount_2_master => pricelist.discount_2, :discount_2_laporan => lap.diskon2,
                      :discount_3_master => pricelist.discount_3, :discount_3_laporan => lap.diskon3,
                      :discount_4_master => pricelist.discount_4, :discount_4_laporan => lap.diskon4,
                      :customer => lap.customer, :tanggal => lap.tanggalsj)
                  end
                else
                  if (lap.hargasatuan != pricelist.prev_harga) || ((lap.nupgrade*lap.jumlah) != pricelist.prev_upgrade) ||
                      (lap.cashback != pricelist.prev_cashback) || (lap.diskon1 != pricelist.prev_discount_1) ||
                      (lap.diskon2 != pricelist.prev_discount_2) || (lap.diskon3 != pricelist.prev_discount_3) ||
                      (lap.diskon4 != pricelist.prev_discount_4)
                    CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal,
                      :kodebarang => lap.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
                      :harga_master => pricelist.prev_harga, :harga_laporan => lap.hargasatuan,
                      :upgrade_master => pricelist.prev_upgrade, :upgrade_laporan => lap.nupgrade,
                      :panjang => lap.panjang, :lebar => lap.lebar,
                      :quantity => lap.jumlah, :checked => false, :bonus => lap.bonus,
                      :cashback_master => pricelist.prev_cashback, :cashback_laporan => lap.cashback,
                      :discount_1_master => pricelist.prev_discount_1, :discount_1_laporan => lap.diskon1,
                      :discount_2_master => pricelist.prev_discount_2, :discount_2_laporan => lap.diskon2,
                      :discount_3_master => pricelist.prev_discount_3, :discount_3_laporan => lap.diskon3,
                      :discount_4_master => pricelist.prev_discount_4, :discount_4_laporan => lap.diskon4,
                      :customer => lap.customer, :tanggal => lap.tanggalsj)
                  end
                end
              else
                if (lap.hargasatuan == pricelist.harga) || ((lap.nupgrade*lap.jumlah) == pricelist.upgrade) ||
                    (lap.cashback == pricelist.cashback) || (lap.diskon1 == pricelist.discount_1) ||
                    (lap.diskon2 == pricelist.discount_2) || (lap.diskon3 == pricelist.discount_3) ||
                    (lap.diskon4 = pricelist.prev_discount_4) && (customer_services == false)
                  customer_services.destroy_all
                end
              end
            end
          end
        end
      end
    end
  end

#  def self.check_lady_test
#    LaporanCabang.where("month(tanggalsj) = ? and year(tanggalsj) = ? and kodebrg not like ? and jenisbrgdisc like ?",
#      11, 2014, %(___________#{'T'}%), "Lady Americana").no_pengajuan.not_equal_with_nosj.each do |lap|
#      unless lap.kodebrg[2].nil?
#        merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
#        unless merk.empty?
#          Cabang.find(lap.cabang_id).regional.each do |cabreg|
#            PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?",
#              merk.first.id, cabreg.id, lap.kodebrg).each do |pricelist|
#              customer_services = CheckedItemMaster.where("tanggal = ? and nofaktur like ? and kodebarang like ? and customer like ? and quantity like ?",
#                lap.tanggalsj, lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah)
#              if customer_services.empty?
#                if pricelist.brand_id == 4 && pricelist.additional_program == true
#                  get_nosj = LaporanCabang.where('nosj like ? and kodejenis in (?) and harganetto1 = ?', lap.nosj, ['HB','DV'], 0)
#                  get_nosj.each do |lapcabfree|
#                    goods = GoodsHeritage.where("child_kodebarang = ? and parent_kodebarang = ? and program_starting_at >= ?", lapcabfree.kodebrg, pricelist.kode_barang, lap.tanggalsj)
#                    if goods.empty?
#                      unless pricelist.parent_items.find_by_child_kodebarang(lapcabfree.kodebrg).nil?
#                        if lap.diskon4 != pricelist.parent_items.find_by_child_kodebarang(lapcabfree.kodebrg).diskon4
#                          CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal,
#                            :kodebarang => lap.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
#                            :harga_master => pricelist.harga, :harga_laporan => lap.hargasatuan,
#                            :upgrade_master => pricelist.upgrade, :upgrade_laporan => lap.nupgrade,
#                            :panjang => lap.panjang, :lebar => lap.lebar,
#                            :quantity => lap.jumlah, :checked => false,
#                            :cashback_master => pricelist.cashback, :cashback_laporan => lap.cashback,
#                            :discount_1_master => pricelist.discount_1, :discount_1_laporan => lap.diskon1,
#                            :discount_2_master => pricelist.discount_2, :discount_2_laporan => lap.diskon2,
#                            :discount_3_master => pricelist.discount_3, :discount_3_laporan => lap.diskon3,
#                            :discount_4_master => pricelist.discount_4, :discount_4_laporan => lap.diskon4,
#                            :customer => lap.customer, :tanggal => lap.tanggalsj)
#                          CheckedItemMaster.create(:nofaktur => lap.nofaktur, :tgl_faktur => lap.tanggal,
#                            :kodebarang => lapcabfree.kodebrg, :namabarang => lap.namabrg, :cabang_id => lap.cabang_id,
#                            :harga_master => pricelist.harga, :harga_laporan => lap.hargasatuan,
#                            :upgrade_master => pricelist.upgrade, :upgrade_laporan => lap.nupgrade,
#                            :panjang => lap.panjang, :lebar => lap.lebar,
#                            :quantity => lap.jumlah, :checked => false,
#                            :cashback_master => pricelist.cashback, :cashback_laporan => lap.cashback,
#                            :discount_1_master => pricelist.discount_1, :discount_1_laporan => lap.diskon1,
#                            :discount_2_master => pricelist.discount_2, :discount_2_laporan => lap.diskon2,
#                            :discount_3_master => pricelist.discount_3, :discount_3_laporan => lap.diskon3,
#                            :discount_4_master => pricelist.discount_4, :discount_4_laporan => lap.diskon4,
#                            :customer => lap.customer, :tanggal => lap.tanggalsj)
#                        end
#                      end
#                    end
#                  end
#                end
#              end
#            end
#          end
#        end
#      end
#    end
#  end
end