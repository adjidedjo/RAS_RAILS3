class PriceList < ActiveRecord::Base

  has_many :parent_items,  :foreign_key => 'parent_item_id',
    :class_name => 'GoodsHeritage',
    :dependent => :destroy
  has_many :child_items,     :through => :parent_items
  has_many :escapes,   :foreign_key => 'child_item_id',
    :class_name => 'GoodsHeritage',
    :dependent => :destroy
  has_many :predators, :through => :escapes
  has_paper_trail
  mount_uploader :image, PriceListUploader, :mount_on => :image_filename

  scope :find_kategori, lambda {|kat| where(jenis: kat) if kat.present?}
  scope :find_tipe, lambda {|tipe| where(produk: tipe) if tipe.present?}
  scope :find_kain, lambda {|kain| where(kain: kain) if kain.present?}

  def self.future_to_price_list
    FuturePriceList.where("DATE(updated_at) = ?", Date.today).each do |fpl|
      PriceList.where("kode_barang like ? and regional_id = ?", fpl.kode_barang, fpl.regional_id).each do |pl|
        if pl.empty?
          PriceList.create(:cabang_id => fpl.cabang_id, :brand_id => fpl.brand_id, :regional_id => fpl.regional_id,
            :jenis => fpl.jenis, :produk => fpl.produk, :kain => fpl.kain,
            :panjang => fpl.panjang, :lebar => fpl.lebar, :harga => fpl.harga, :prev_harga => fpl.harga,
            :discount_1 => fpl.discount_1, :prev_discount_1 => fpl.discount_1,
            :discount_2 => fpl.discount_2, :prev_discount_2 => fpl.discount_2,
            :discount_3 => fpl.discount_3, :prev_discount_3 => fpl.discount_3,
            :discount_4 => fpl.discount_4, :prev_discount_4 => fpl.discount_4,
            :upgrade => fpl.upgrade, :prev_upgrade => fpl.upgrade,
            :cashback => fpl.upgrade, :prev_cashback => fpl.cashback,
            :special_price => fpl.special_price, :prev_special_price => fpl.special_price,
            :kode_barang => fpl.kode_barang, :nama => fpl.nama)
        elsif fpl.harga_starting_at == Date.today
          pl.update_attributes!(:harga => fpl.harga, :prev_harga => pl.harga)
        elsif fpl.discount_starting_at == Date.today
          pl.update_attributes!(
            :discount_1 => fpl.discount_1, :prev_discount_1 => pl.discount_1,
            :discount_2 => fpl.discount_2, :prev_discount_2 => pl.discount_2,
            :discount_3 => fpl.discount_3, :prev_discount_3 => pl.discount_3,
            :discount_4 => fpl.discount_4, :prev_discount_4 => pl.discount_4)
        elsif fpl.upgrade_starting_at == Date.today
          pl.update_attributes!(:upgrade => fpl.upgrade, :prev_upgrade => pl.upgrade)
        elsif fpl.cashback_starting_at == Date.today
          pl.update_attributes!(:cashback => fpl.cashback, :prev_cashback => pl.cashback)
        else fpl.special_price_starting_at == Date.today
          pl.update_attributes!(:special_price => fpl.special_price, :prev_special_price => pl.special_price)
        end
      end
    end
  end

  def self.check_availability_master(bulan, tahun)
    LaporanCabang.compare_price_list(bulan, tahun).each do |lap|
      merk = Merk.where("IdMerk like ?", "#{lap.kodebrg[2]}")
      unless merk.empty?
        regional = Cabang.find(lap.cabang_id).regional.find_by_brand_id(merk.first.id)
        unless regional.nil?
          future_price_list = FuturePriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?", merk.first.id, regional.id, lap.kodebrg)
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
              customer_services = CheckedItemMaster.where("tanggal = ? and nofaktur like ? and kodebarang like ? and customer like ? and quantity like ? and no_so like ?",
                lap.tanggalsj, lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah, lap.noso)
              if customer_services.empty?
                if lap.tanggalsj.month == bulan
                  if (lap.hargasatuan != pricelist.harga) || ((lap.nupgrade*lap.jumlah) != pricelist.upgrade) ||
                      (lap.cashback != pricelist.cashback) || (lap.diskon1 != pricelist.discount_1) ||
                      (lap.diskon2 != pricelist.discount_2) || (lap.diskon3 != pricelist.discount_3) ||
                      (lap.diskon4 != pricelist.discount_4)
                    LaporanCabang.where(nofaktur: lap.nofaktur).each do |noso|
                      PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?",
                        merk.first.id, cabreg.id, noso.kodebrg).each do |pricelist_noso|
                        CheckedItemMaster.create(:nofaktur => noso.nofaktur, :tgl_faktur => noso.tanggal,
                          :kodebarang => noso.kodebrg, :namabarang => noso.namabrg, :cabang_id => noso.cabang_id,
                          :harga_master => pricelist_noso.nil? ? 0 : pricelist_noso.harga, :harga_laporan => noso.hargasatuan,
                          :upgrade_master => pricelist_noso.nil? ? 0 : pricelist_noso.upgrade, :upgrade_laporan => noso.nupgrade,
                          :panjang => noso.panjang, :lebar => noso.lebar, :netto2 => noso.harganetto2,
                          :quantity => noso.jumlah, :checked => false, :bonus => noso.bonus,
                          :cashback_master => pricelist_noso.nil? ? 0 : pricelist_noso.cashback, :cashback_laporan => noso.cashback,
                          :discount_1_master => pricelist_noso.nil? ? 0 : pricelist_noso.discount_1, :discount_1_laporan => noso.diskon1,
                          :discount_2_master => pricelist_noso.nil? ? 0 : pricelist_noso.discount_2, :discount_2_laporan => noso.diskon2,
                          :discount_3_master => pricelist_noso.nil? ? 0 : pricelist_noso.discount_3, :discount_3_laporan => noso.diskon3,
                          :discount_4_master => pricelist_noso.nil? ? 0 : pricelist_noso.discount_4, :discount_4_laporan => noso.diskon4,
                          :customer => noso.customer, :tanggal => noso.tanggalsj, :no_so => noso.noso)
                      end
                    end
                  end
                else
                  if (lap.hargasatuan != pricelist.prev_harga) || ((lap.nupgrade*lap.jumlah) != pricelist.prev_upgrade) ||
                      (lap.cashback != pricelist.prev_cashback) || (lap.diskon1 != pricelist.prev_discount_1) ||
                      (lap.diskon2 != pricelist.prev_discount_2) || (lap.diskon3 != pricelist.prev_discount_3) ||
                      (lap.diskon4 != pricelist.prev_discount_4)
                    LaporanCabang.where(nofaktur: lap.nofaktur).each do |noso|
                      PriceList.where("brand_id = ? and regional_id = ? and kode_barang like ?",
                        merk.first.id, cabreg.id, noso.kodebrg).each do |pricelist_noso|
                        CheckedItemMaster.create(:nofaktur => noso.nofaktur, :tgl_faktur => noso.tanggal,
                          :kodebarang => noso.kodebrg, :namabarang => noso.namabrg, :cabang_id => noso.cabang_id,
                          :harga_master => pricelist_noso.nil? ? 0 : pricelist.prev_harga, :harga_laporan => noso.hargasatuan,
                          :upgrade_master => pricelist_noso.nil? ? 0 : pricelist.prev_upgrade, :upgrade_laporan => noso.nupgrade,
                          :panjang => noso.panjang, :lebar => noso.lebar, :netto2 => noso.harganetto2,
                          :quantity => noso.jumlah, :checked => false, :bonus => noso.bonus,
                          :cashback_master => pricelist_noso.nil? ? 0 : pricelist.prev_cashback, :cashback_laporan => noso.cashback,
                          :discount_1_master => pricelist_noso.nil? ? 0 : pricelist.prev_discount_1, :discount_1_laporan => noso.diskon1,
                          :discount_2_master => pricelist_noso.nil? ? 0 : pricelist.prev_discount_2, :discount_2_laporan => noso.diskon2,
                          :discount_3_master => pricelist_noso.nil? ? 0 : pricelist.prev_discount_3, :discount_3_laporan => noso.diskon3,
                          :discount_4_master => pricelist_noso.nil? ? 0 : pricelist.prev_discount_4, :discount_4_laporan => noso.diskon4,
                          :customer => noso.customer, :tanggal => noso.tanggalsj, :no_so => noso.noso)
                      end
                    end
                  end
                end
              else
                if lap.tanggalsj.month == bulan
                  if (lap.hargasatuan == pricelist.harga) && ((lap.nupgrade*lap.jumlah) == pricelist.upgrade) &&
                      (lap.cashback == pricelist.cashback) && (lap.diskon1 == pricelist.discount_1) &&
                      (lap.diskon2 == pricelist.discount_2) && (lap.diskon3 == pricelist.discount_3) &&
                      (lap.diskon4 == pricelist.discount_4)
                    match_customer_services = CheckedItemMaster.where("tanggal = ? and nofaktur like ? and kodebarang like ? and customer like ? and quantity like ?",
                      lap.tanggalsj, lap.nofaktur, lap.kodebrg, lap.customer, lap.jumlah)
                    match_customer_services.first.destroy
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def self.future_to_price
    FuturePriceList.all.each do |fpl|
      get_pl = PriceList.find_by_kode_barang_and_brand_id_and_regional_id(fpl.kode_barang, fpl.brand_id, fpl.regional_id)
      if get_pl.nil?
        PriceList.create!(:kode_barang => fpl.kode_barang,
          :nama => fpl.nama,
          :brand_id => fpl.brand_id,
          :jenis => fpl.jenis,
          :produk => fpl.produk,
          :kain => fpl.kain,
          :panjang => fpl.panjang,
          :lebar => fpl.lebar,
          :prev_harga => fpl.harga,
          :harga => fpl.harga,
          :prev_discount_1 => fpl.discount_1,
          :discount_1 => fpl.discount_1,
          :prev_discount_2 => fpl.discount_2,
          :discount_2 => fpl.discount_2,
          :prev_discount_3 => fpl.discount_3,
          :discount_3 => fpl.discount_3,
          :prev_discount_4 => fpl.discount_4,
          :discount_4 => fpl.discount_4,
          :prev_upgrade => fpl.upgrade,
          :upgrade => fpl.upgrade,
          :prev_cashback => fpl.cashback,
          :cashback => fpl.cashback,
          :prev_special_price => fpl.special_price,
          :special_price => fpl.special_price,
          :regional_id => fpl.regional_id,
          :additional_program => 0,
          :additional_diskon => 0
        )
      end
    end
  end
end