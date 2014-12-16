class SqlSales < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "sqlserver"
  set_table_name "tbLaporanCabang"

  def self.migration_sales_report(month, year)
    select("*").where("month(tanggalsj) = ? and year(tanggalsj) = ? and jenisbrgdisc is not null", month, year).each do |sql_sales|
      lapcab = LaporanCabang.find_by_cabang_id_and_tanggalsj_and_nofaktur_and_kodebrg_and_customer_and_jumlah(sql_sales.idcabang.to_i,
        sql_sales.tanggalsj,sql_sales.nofaktur, sql_sales.kodebrg, sql_sales.customer, sql_sales.jumlah)
      if lapcab.nil?
        LaporanCabang.create(cabang_id: sql_sales.idcabang,
          nosj: sql_sales.nosj,
          tanggal: sql_sales.tanggalfaktur,
          tanggalsj: sql_sales.tanggalsj,
          nofaktur: sql_sales.nofaktur,
          noso: sql_sales.noso,
          kode_customer: sql_sales.kodecust,
          customer: sql_sales.customer,
          alamatkirim: sql_sales.alamatkirim,
          salesman: sql_sales.salesman,
          kodebrg: sql_sales.kodebrg,
          namabrg: sql_sales.namabrg,
          jenisbrgdisc: sql_sales.jenisbrgdisc,
          kodejenis: sql_sales.kodejenis,
          jenisbrg: sql_sales.jenisbrg,
          kodeartikel: sql_sales.kodeartikel,
          namaartikel: sql_sales.namaartikel,
          kodekain: sql_sales.kodekain,
          namakain: sql_sales.namakain,
          panjang: sql_sales.panjang,
          lebar: sql_sales.lebar,
          jumlah: sql_sales.jumlah,
          satuan: sql_sales.satuan,
          hargasatuan: sql_sales.hargasatuan,
          hargabruto: sql_sales.hargabruto,
          diskon1: sql_sales.diskon1,
          diskon2: sql_sales.diskon2,
          diskon3: sql_sales.diskon3,
          diskon4: sql_sales.diskon4,
          diskon5: sql_sales.diskon5,
          diskonsum: sql_sales.diskonsum,
          diskonrp: sql_sales.diskonrp,
          harganetto1: sql_sales.harganetto1,
          harganetto2: sql_sales.harganetto2,
          totalnetto1: sql_sales.totalnetto1,
          totalnetto2: sql_sales.totalnetto2,
          totalnettofaktur: sql_sales.totalnettofaktur,
          cashback: sql_sales.cashback,
          nupgrade: sql_sales.nupgrade,
          ketppb: sql_sales.ketppb,
          kota: sql_sales.kota,
          Jenis_Customer: sql_sales.tipecust,
          namabrand: sql_sales.namabrand,
          bonus: sql_sales.bonus,
          groupcust: sql_sales.groupcust,
          plankinggroup: sql_sales.plankinggroup
        )
      elsif sql_sales.bonus != 'BONUS' || sql_sales.harganetto2 != 0
        lapcab.update_attributes!(cabang_id: sql_sales.idcabang,
          nosj: sql_sales.nosj,
          tanggal: sql_sales.tanggalfaktur,
          tanggalsj: sql_sales.tanggalsj,
          nofaktur: sql_sales.nofaktur,
          noso: sql_sales.noso,
          kode_customer: sql_sales.kodecust,
          customer: sql_sales.customer,
          alamatkirim: sql_sales.alamatkirim,
          salesman: sql_sales.salesman,
          kodebrg: sql_sales.kodebrg,
          namabrg: sql_sales.namabrg,
          jenisbrgdisc: sql_sales.jenisbrgdisc,
          kodejenis: sql_sales.kodejenis,
          jenisbrg: sql_sales.jenisbrg,
          kodeartikel: sql_sales.kodeartikel,
          namaartikel: sql_sales.namaartikel,
          kodekain: sql_sales.kodekain,
          namakain: sql_sales.namakain,
          panjang: sql_sales.panjang,
          lebar: sql_sales.lebar,
          jumlah: sql_sales.jumlah,
          satuan: sql_sales.satuan,
          hargasatuan: sql_sales.hargasatuan,
          hargabruto: sql_sales.hargabruto,
          diskon1: sql_sales.diskon1,
          diskon2: sql_sales.diskon2,
          diskon3: sql_sales.diskon3,
          diskon4: sql_sales.diskon4,
          diskon5: sql_sales.diskon5,
          diskonsum: sql_sales.diskonsum,
          diskonrp: sql_sales.diskonrp,
          harganetto1: sql_sales.harganetto1,
          harganetto2: sql_sales.harganetto2,
          totalnetto1: sql_sales.totalnetto1,
          totalnetto2: sql_sales.totalnetto2,
          totalnettofaktur: sql_sales.totalnettofaktur,
          cashback: sql_sales.cashback,
          nupgrade: sql_sales.nupgrade,
          ketppb: sql_sales.ketppb,
          kota: sql_sales.kota,
          Jenis_Customer: sql_sales.tipecust,
          namabrand: sql_sales.namabrand,
          bonus: sql_sales.bonus,
          groupcust: sql_sales.groupcust,
          plankinggroup: sql_sales.plankinggroup)
      end
    end
  end

  def self.customer_migration(month, year)
    select("*").where("month(tanggalsj) = ? and year(tanggalsj) = ? and jenisbrgdisc is not null", month, year).each do |sql_cust|
      customer = Customer.find_by_nama_customer_and_kode_customer_and_cabang_id(sql_cust.customer, sql_cust.kodecust, sql_cust.idcabang)
      if customer.nil?
        Customer.create(kode_customer: sql_cust.kodecust,
        cabang_id: sql_cust.idcabang,
        nama_customer: sql_cust.customer,
        tipe_customer: sql_cust.tipecust,
        group_customer: sql_cust.groupcust,
        flankin_customer: sql_cust.plankinggroup)
      end
    end
  end
end
