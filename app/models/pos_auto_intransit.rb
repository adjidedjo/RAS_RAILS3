class PosAutoIntransit < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "exhibition_stock_items"

  def self.insert_delivered_stock_from_jde
    PosChannelCustomer.where("address_number > ?", 0).each do |pcc|
      SalesOrderHistoryJde.find_sales_transfer_to_showroom(Date.today, pcc.address_number).each do |soh|
        stocking_type = soh.sdmcu.include? "D" ? "RE" : "CS"
        jde_date_today = jde_date_to_date(soh.sdaddj.to_i)
        nama_brg = soh.sddsc1.strip + " " + soh.sddsc2.strip
        duplicate_stock = self.where(channel_customer_id: pcc.id, serial: soh.sdlotn, kode_barang: soh.sdaitm.strip, no_sj: soh.sddeln)
        if duplicate_stock.blank?
          self.create(channel_customer_id: pcc.id, serial: soh.sdlotn.strip, kode_barang: soh.sdaitm.strip, no_sj: soh.sddeln.to_i, nama: nama_brg,
            jumlah: soh.sdsoqs.to_i.to_s[0..-5], stok_awal: soh.sdsoqs.to_i.to_s[0..-5], no_so: soh.sddoco.to_i, tanggal_sj: jde_date_today, stocking_type: stocking_type)
          item_masters = PosItemMaster.find_by_kode_barang(soh.sdaitm.strip)
          if item_masters.present?
            item_masters.update_attributes!(nama: nama_brg)
          end
        end
      end
    end
  end

  def self.jde_date_to_date(date)
    Date.parse((date+1900000).to_s, 'YYYYYDDD')
  end
end