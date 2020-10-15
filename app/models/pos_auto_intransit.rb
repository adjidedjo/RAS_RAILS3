class PosAutoIntransit < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "exhibition_stock_items"
  
  def self.insert_pos_to_jde
    ps = ActiveRecord::Base.connection.execute("
      SELECT sales.no_so AS no_order, UPPER(IFNULL(puc.nama_ktp, puc.nama)) AS penerima, 
      UPPER(IFNULL(puc.alamat_ktp, puc.alamat)) AS alamat_penerima, puc.no_telepon AS telepon, IFNULL(puc.nik, '-') AS no_ktp FROM
      (
        SELECT * FROM point_of_sales_staging.sales WHERE DATE(created_at) = '#{Date.yesterday.to_date}' AND cancel_order = 0
      ) AS sales
      LEFT JOIN
      (
        SELECT * FROM point_of_sales_staging.pos_ultimate_customers
      ) AS puc ON puc.id = pos_ultimate_customer_id
    ")
    
    ps.each do |a|
      JdeInvoiceProcessing.insert_pos_to_jde(a)
    end
  end

  def self.insert_delivered_stock_from_jde(date)
    PosChannelCustomer.where("address_number > ?", 0).each do |pcc|
      SalesOrderHistoryJde.find_sales_transfer_to_showroom(date.to_date, pcc.address_number).each do |soh|
        stocking_type = (soh.sdmcu.include? "D") ? "RE" : "CS"
        jde_date_today = jde_date_to_date(soh.sdaddj.to_i)
        nama_brg = soh.sddsc1.strip + " " + soh.sddsc2.strip
        duplicate_stock = self.where(channel_customer_id: pcc.id, serial: soh.sdlotn, kode_barang: soh.sdlitm.strip, no_sj: soh.sddeln)
        if duplicate_stock.blank?
          self.create(channel_customer_id: pcc.id, serial: soh.sdlotn.strip, kode_barang: soh.sdlitm.strip, no_sj: soh.sddeln.to_i, nama: nama_brg,
            jumlah: soh.sdsoqs.to_i.to_s[0..-5], stok_awal: soh.sdsoqs.to_i.to_s[0..-5], no_so: soh.sddoco.to_i, tanggal_sj: jde_date_today, stocking_type: stocking_type)
          item_masters = PosItemMaster.find_by_kode_barang(soh.sdlitm.strip)
          if item_masters.present?
            item_masters.update_attributes!(nama: nama_brg)
          end
        end
      end
    end
  end
  
  def self.get_delivery_number_from_jde
    PosSales.where("month(created_at) >= 9 and year(created_at) >= 2020 and 
    (delivery_number is null or delivery_number = 0)").each do |ps|
      JdeInvoice.get_delivery_number(ps.no_so).each do |jde_del|
        ps.update_attributes(:delivery_number => jde_del['sddeln'], :invoice_number => jde_del['sddoc'])
      end
    end
  end

  def self.jde_date_to_date(date)
    Date.parse((date+1900000).to_s, 'YYYYYDDD')
  end
end
