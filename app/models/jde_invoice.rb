class JdeInvoice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f03b11" #sd
  
  def self.test_import_sales
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpdicj BETWEEN '#{date_to_julian('14/08/2018'.to_date)}' AND '#{date_to_julian('14/08/2018'.to_date)}'  
    AND REGEXP_LIKE(rpdct,'RI|RX|RO|RM') AND rpsdoc > 1 AND rpmcu LIKE '%1801201'")
    invoices.each do |iv|
        customer = JdeCustomerMaster.find_by_aban8(iv.rpan8)
        bonus = iv.rpag.to_i == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C"
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(iv.rpmcu.to_i.to_s.strip)
          area = find_area(cabang)
          item_master = JdeItemMaster.get_item_number_from_secondget_item_number_from_second(iv.rprmk.strip)
          fullnamabarang = "#{item_master.imdsc1.strip} " "#{item_master.imdsc2.strip}"
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(item_master.imsrp3.strip)
          # harga = JdeBasePrice.harga_satuan(order.sditm, order.sdmcu.strip, order.sdtrdj)
          kota = JdeAddressByDate.get_city(iv.rpan8.to_i)
          group = JdeCustomerMaster.get_group_customer(iv.rpan8.to_i)
          # variance = order.sdaddj == 0 ? 0 : (julian_to_date(order.sdaddj)-julian_to_date(order.sdppdj)).to_i
          sales = JdeSalesman.find_salesman(iv.rpan8.to_i, item_master.imsrp1.strip)
          sales_id = JdeSalesman.find_salesman_id(iv.rpan8.to_i, item_master.imsrp1.strip)
          customer_master = Customer.where(address_number: iv.rpan8.to_i)
          customer_brand = CustomerBrand.where(address_number: iv.rpan8.to_i, brand: item_master.imprgr.strip)
          if customer_brand.empty? || customer_brand.nil?
            CustomerBrand.create!(address_number: iv.rpan8.to_i, brand: item_master.imprgr.strip, 
            last_order: julian_to_date(iv.rpdivj), branch: area, customer: namacustomer, channel_group: group)
          elsif customer_brand.first.last_order != julian_to_date(iv.rpdivj)
            customer_brand.first.update_attributes!(last_order: julian_to_date(iv.rpdivj), branch: area)
            # customer_master.first.update_attributes!(last_order_date: julian_to_date(order.sdaddj))
          end
          sales_type = iv.rpmcu.to_i.to_s.strip.include?("K") ? 1 : 0 #checking if konsinyasi
          LaporanCabang.create(cabang_id: cabang, noso: iv.rpsdoc.to_i, tanggalsj: julian_to_date(iv.rpdivj),
            kodebrg: item_master.imlitm.strip,
            namabrg: fullnamabarang, kode_customer: iv.rpan8.to_i, customer: namacustomer, jumlah: iv.rpu.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..7], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            harganetto1: iv.rpag, harganetto2: iv.rpag, kota: kota, tipecust: group, bonus: bonus, ketppb: "",
            salesman: sales, orty: iv.rpdct.strip, nopo: sales_id, fiscal_year: julian_to_date(iv.rpdivj).to_date.year,
            fiscal_month: julian_to_date(iv.rpdivj).to_date.month, week: julian_to_date(iv.rpdivj).to_date.cweek,
            area_id: area, ketppb: iv.rpmcu.strip, totalnetto1: sales_type, tanggal: julian_to_date(iv.rpdivj))
         end
      end
  end

  private
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
  
  def self.find_area(cabang)
    if cabang == "02"
      2
    elsif cabang == "01"
      1
    elsif cabang == "03" || cabang == "23"
      3
    elsif cabang == "07" || cabang == "22"
      7
    elsif cabang == "09"
      9
    elsif cabang == "04"
      4
    elsif cabang == "05"
      5
    elsif cabang == "08"
      8
    elsif cabang == "10"
      10
    elsif cabang == "11"
      11
    elsif cabang == "13"
      13
    elsif cabang == "19"
      19
    elsif cabang == "20"
      20
    elsif cabang == "50"
      50
    elsif cabang == "25"
      25
    elsif cabang == "26"
      26
    end
  end
  
  def self.jde_cabang(bu)
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" #pusat
      "01"
    elsif bu == "11101" || bu == "11102" || bu == "11101C" || bu == "11101D" || bu == "11101S" || bu == "18101" || bu == "18101C" || bu == "18101D" || bu == "18102" || bu == "18101S" || bu == "18101K" #lampung
      "13" 
    elsif bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18012" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" #surabaya
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "12111C" || bu == "12111D" || bu == "12111S" || bu == "18111" || bu == "18111C" || bu == "18111D" || bu == "18112" || bu == "18111S" || bu == "18111K" || bu == "18112C" || bu == "18112D" || bu == "18112K" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "12071C" || bu == "12071D" || bu == "12071S" || bu == "18071" || bu == "18071C" || bu == "18071D" || bu == "18072" || bu == "18071S" || bu == "18071K" || bu == "18072C" || bu == "18071D" || bu == "18071K" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "12131C" || bu == "12131D" || bu == "12131S" || bu == "18131" || bu == "18131C" || bu == "18131D" || bu == "18132" || bu == "18131S" || bu == "18131K" || bu == "18132C" || bu == "18132D" || bu == "18132K" #jember
      "22" 
    elsif bu == "11091" || bu == "11092" || bu == "11091C" || bu == "11091D" || bu == "11091S" || bu == "18091" || bu == "18091C" || bu == "18091D" || bu == "18092" || bu == "18091S" || bu == "18091K" || bu == "18092C" || bu == "18092D" || bu == "18092K" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "11041C" || bu == "11041D" || bu == "11041S" || bu == "18041" || bu == "18041C" || bu == "18041D" || bu == "18042" || bu == "18042S" || bu == "18042K" || bu == "18042C" || bu == "18042D" || bu == "18042K" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "11051C" || bu == "11051D" || bu == "11051S" || bu == "18051" || bu == "18051C" || bu == "18051D" || bu == "18052" || bu == "18051S" || bu == "18051K" || bu == "18052C" || bu == "18052D" || bu == "18052K" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "11081C" || bu == "11081D" || bu == "11081S" || bu == "18081" || bu == "18081C" || bu == "18081D" || bu == "18082" || bu == "18081S" || bu == "18081K" || bu == "18082C" || bu == "18082D" || bu == "18082K" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "11121C" || bu == "11121D" || bu == "11121S" || bu == "18121" || bu == "18121C" || bu == "18121D" || bu == "18122" || bu == "18121S" || bu == "18121K" || bu == "18122C" || bu == "18122D" || bu == "18122K" #pekanbaru
      "20"
    elsif bu == "1801201" || bu == "1801202" || bu == "1801201C" || bu == "1801201D" || bu == "1801201S" || bu == "1801201" || bu == "1801201C" || bu == "1801201D" || bu == "1801201" || bu == "1801201S" || bu == "1801201K" || bu == "1801201C" || bu == "1801201D" || bu == "1801201K" #tasikmalaya
      "25"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    end
  end
end