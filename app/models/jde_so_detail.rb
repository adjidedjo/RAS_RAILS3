class JdeSoDetail < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4211" #sd

  def self.outstanding_so(item_number, first_week, branch_plan)
    select("sum(sduorg) as sduorg").where("sditm = ? and sdnxtr < ? and sdlttr < ? and sddcto like ? and sdtrdj = ? and sdmcu like ?",
      item_number, "999", "580", "SO", date_to_julian(first_week), "%#{branch_plan}%")
  end

  def self.delivered_so(item_number, first_week, last_week)
    select("sum(sdsoqs) as sdsoqs").where("sditm = ? and sdnxtr = ? and sdlttr = ? and sddcto like ? and sdaddj = ?",
      item_number, "999", "580", "SO", date_to_julian(first_week))
  end

  # #jde to mysql tblaporancabang
  def self.import_so_detail
    where("sdnxtr >= ? and sdlttr >= ? and sddcto = ? and sdaddj = ?",
    "580", "565", "SO", date_to_julian(Date.today)).each do |a|
      find_sj = LaporanCabang.where(nosj: a.sddeln.to_i, lnid: a.sdlnid.to_i)
      if find_sj.empty?
        fullnamabarang = "#{a.sddsc1.strip} " "#{a.sddsc2.strip}"
        customer = JdeCustomerMaster.find_by_aban8(a.sdan8)
        bonus = a.sdaexp == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C"
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(a.sdmcu.to_i.to_s.strip)
          item_master = JdeItemMaster.find_by_imitm(a.sditm)
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(a.sdsrp3.strip)
          harga = JdeBasePrice.harga_satuan(a.sditm, a.sdmcu.strip, a.sdtrdj)
          kota = JdeAddressByDate.get_city(a.sdan8.to_i)
          group = JdeCustomerMaster.get_group_customer(a.sdan8.to_i)
         sales = JdeSalesman.find_salesman(a.sdan8.to_i, a.sdsrp1.strip)
          LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdaddj),kodebrg: a.sdaitm.strip,
            namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, tipecust: group, bonus: bonus, lnid: a.sdlnid.to_i, ketppb: "",
            salesman: sales)
        end
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
    if bu == "11001" || bu == "11002" #pusat
      "01"
    elsif bu == "11011" || bu == "11012" #jabar
      "02"
    elsif bu == "11021" || bu == "11022" #cirebon
      "09"
    elsif bu == "12061" || bu == "12062" || bu == "12001" #bestari mulia
      "07"
    elsif bu == "11151" || bu == "11152" #cikupa
      "23"
    elsif bu == "11031" || bu == "11032" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" #bali
      "04"
    elsif bu == "12071" || bu == "12072" #jember
      "04"
    elsif bu == "12131" || bu == "12132" #jember
      "04"
    end
  end
end