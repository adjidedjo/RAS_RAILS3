class JdeSoDetail < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4211" #sd

  # #jde to mysql tblaporancabang
  def self.import_so_detail
    where(sdnxtr: "999", sdlttr: "580", sddcto: "SO").where("sdaddj = ?", date_to_julian("01-02-2016".to_date)).each do |a|
      fullnamabarang = "#{a.sddsc1.strip} " "#{a.sddsc2.strip}"
      customer = JdeCustomerMaster.find_by_aban8(a.sdan8)
      if customer.abat1.strip == "C"
        namacustomer = customer.abalph.strip
        cabang = jde_cabang(a.sdmcu.to_i.to_s[2..3])
        item_master = JdeItemMaster.find_by_imitm(a.sditm)
        jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
        artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
        kain = JdeUdc.kain_udc(item_master.imseg3.strip)
        groupitem = JdeUdc.group_item_udc(a.sdsrp3.strip)
        harga = JdeBasePrice.harga_satuan(a.sditm, a.sdmcu.strip, a.sdtrdj)
        kota = JdeAddressByDate.get_city(a.sdan8.to_i)
        group = JdeCustomerByLine.get_group_customer(a.sdan8.to_i, a.sdkcoo.to_i)
        LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdaddj),kodebrg: a.sdaitm.strip,
          namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
          jenisbrgdisc: a.sdprgr, kodejenis: item_master.imseg1, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
          kodekain: item_master.imseg3, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
          hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, groupcust: group)
      end
    end
  end

  private
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

  def self.julian_to_date(jd_date)
    Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
  end

  def self.jde_cabang(bu)
    if bu == "00"
      "01"
    elsif bu == "01"
      "02"
    end
  end
end