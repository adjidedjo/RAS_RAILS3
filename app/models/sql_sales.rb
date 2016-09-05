class SqlSales < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "sqlserver"
  #  set_table_name "VLaporanCabang"
  set_table_name "tbLaporanCabang"

  scope :without_batal, where("kodebrg not like ? and kodebrg not like ?", "batal", "")
  scope :search_by_branch, lambda {|branch| where("idcabang in (?)", branch) if branch.present? }
  scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
  scope :search_by_year, lambda { |year| where("YEAR(tanggalsj) = ?", year)}
  scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and ketppb not like ?", %(#{'SJB'}%), %(#{'SJP'}%), %(#{'RD'}%))

  def self.sales_by_brand_by_branch_sql_sales(bulan, tahun, branch)
    select("idcabang, jenisbrgdisc, SUM(jumlah) sum_jumlah, SUM(harganetto2) sum_harganetto2").search_by_month_and_year(bulan, tahun).search_by_branch(branch).not_equal_with_nosj.group(:idcabang, :jenisbrgdisc).each do |lapcab|
      sales_brand = SalesBrand.find_by_bulan_and_tahun_and_cabang_id_and_merk(bulan, tahun, lapcab.idcabang, lapcab.jenisbrgdisc)
      if sales_brand.nil?
        SalesBrand.create(:cabang_id => lapcab.idcabang, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => lapcab.jenisbrgdisc, :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.change_brand(brand)
    if brand == "Non Serenity" || brand == "Accessoris Elite"
      "ELITE"
    elsif brand == "Lady Americana" || brand == "Accessoris Lady"
      "LADY"
    elsif brand == "Royal"
      "ROYAL"
    elsif brand == "Serenity"
      "SERENITY"
    end
  end

  def self.migration_sales_report
    @sqlnosj = []
    ActiveRecord::Base.transaction do
      SqlSales.find_by_sql("SELECT idcabang, nosj, tanggalfaktur, tanggalsj, nofaktur, noso, nopo,
        kodecust, customer, alamatkirim, salesman, kodebrg, namabrg, jenisbrgdisc, kodejenis,
        jenisbrg, kodeartikel, namaartikel, kodekain, namakain, panjang, lebar, jumlah, satuan,
        hargasatuan, hargabruto, diskon1, diskon2, diskon3, diskon4, diskon5, diskonsum, diskonrp,
        harganetto1, harganetto2, totalnetto1, totalnetto2, totalnettofaktur, cashback, nupgrade,
        ketppb, kota, tipecust, namabrand, bonus, groupcust, plankinggroup, tanggalinput FROM tbLaporanCabang 
        WHERE DATEDIFF(dd, tanggalinput,'20160901') = 0").each do |sql_sales|
          lapcab = LaporanCabang.find_by_sql(["SELECT nosj, tanggal, tanggalsj, nofaktur, noso, nopo,
        kode_customer, customer, alamatkirim, salesman, kodebrg, namabrg, jenisbrgdisc, kodejenis,
        jenisbrg, kodeartikel, namaartikel, kodekain, namakain, panjang, lebar, jumlah, satuan,
        hargasatuan, hargabruto, diskon1, diskon2, diskon3, diskon4, diskon5, diskonsum, diskonrp,
        harganetto1, harganetto2, totalnetto1, totalnetto2, totalnettofaktur, cashback, nupgrade,
        ketppb, kota, tipecust, namabrand, bonus, groupcust, plankinggroup, tanggal_fetched, tanggal_upload
        from tblaporancabang WHERE nosj LIKE ? AND kodebrg LIKE ? AND bonus LIKE ? AND ketppb LIKE ?", 
        sql_sales.nosj, sql_sales.kodebrg, sql_sales.bonus, sql_sales.ketppb])
        lapcab = LaporanCabang.find_by_nosj_and_kodebrg_and_bonus_and_ketppb(sql_sales.nosj, sql_sales.kodebrg, sql_sales.bonus, sql_sales.ketppb)
        if lapcab.nil?
          brand = change_brand(sql_sales.jenisbrgdisc)
          LaporanCabang.connection.execute("INSERT INTO tblaporancabang (cabang_id, nosj ,tanggalsj, noso, kode_customer,
          customer, salesman, kodebrg, namabrg, jenisbrgdisc, kodejenis, jenisbrg, kodeartikel,
          namaartikel, kodekain, panjang, lebar, jumlah, hargasatuan, hargabruto, harganetto1, 
          harganetto2, ketppb, kota, tipecust, namabrand, bonus, groupcust, plangkinggroup,
          tanggal_fetched, tanggal_upload) VALUES ('#{sql_sales.idcabang}','#{sql_sales.nosj}','#{sql_sales.tanggalsj}','#{sql_sales.noso}', '#{sql_sales.kodecust}',
            '#{sql_sales.customer}','#{sql_sales.salesman}','#{sql_sales.kodebrg}','#{sql_sales.namabrg}',
            '#{brand}','#{sql_sales.kodejenis}','#{sql_sales.jenisbrg}','#{sql_sales.kodeartikel}',
            '#{sql_sales.namaartikel}','#{sql_sales.kodekain}','#{sql_sales.panjang}','#{sql_sales.lebar}',
            '#{sql_sales.jumlah}','#{sql_sales.satuan}','#{sql_sales.hargasatuan}','#{sql_sales.hargabruto}','#{sql_sales.harganetto1}',
            '#{sql_sales.harganetto2}','#{sql_sales.ketppb}','#{sql_sales.kota}','#{sql_sales.tipecust}','#{sql_sales.namabrand}',
            '#{sql_sales.bonus}','#{sql_sales.groupcust}','#{sql_sales.plankinggroup}','#{Date.today}','#{sql_sales.tanggalinput}')")
        elsif (lapcab.nosj == sql_sales.nosj) && (lapcab.tanggal_upload.to_formatted_s(:short) != sql_sales.tanggalinput.to_formatted_s(:short))
          lapcab.update_attributes!(
            nofaktur: sql_sales.nofaktur,
            jenisbrgdisc: change_brand(sql_sales.jenisbrgdisc),
            kodejenis: sql_sales.kodejenis,
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
            bonus: sql_sales.bonus,
            tanggal_upload: sql_sales.tanggalinput)
        end
        @sqlnosj << sql_sales.nosj
      end
      @sqlnosj.each do |sqlnosj|
        sanosj = LaporanCabang.where(nosj: sqlnosj)
        sonosj = SqlSales.where(nosj: sqlnosj)
        if sanosj != sonosj
          sanosj.connection.execute("DELETE FROM tblaporancabang WHERE nosj like '#{sqlnosj}'")
          sonosj.each do |sql_sales|
            LaporanCabang.connection.execute("INSERT INTO tblaporancabang (cabang_id, nosj ,tanggalsj, noso, kode_customer,
          customer, salesman, kodebrg, namabrg, jenisbrgdisc, kodejenis, jenisbrg, kodeartikel,
          namaartikel, kodekain, panjang, lebar, jumlah, hargasatuan, hargabruto, harganetto1, 
          harganetto2, ketppb, kota, tipecust, namabrand, bonus, groupcust, plangkinggroup,
          tanggal_fetched, tanggal_upload) VALUES ('#{sql_sales.idcabang}','#{sql_sales.nosj}','#{sql_sales.tanggalsj}','#{sql_sales.noso}', '#{sql_sales.kodecust}',
            '#{sql_sales.customer}','#{sql_sales.salesman}','#{sql_sales.kodebrg}','#{sql_sales.namabrg}',
            '#{brand}','#{sql_sales.kodejenis}','#{sql_sales.jenisbrg}','#{sql_sales.kodeartikel}',
            '#{sql_sales.namaartikel}','#{sql_sales.kodekain}','#{sql_sales.panjang}','#{sql_sales.lebar}',
            '#{sql_sales.jumlah}','#{sql_sales.satuan}','#{sql_sales.hargasatuan}','#{sql_sales.hargabruto}','#{sql_sales.harganetto1}',
            '#{sql_sales.harganetto2}','#{sql_sales.ketppb}','#{sql_sales.kota}','#{sql_sales.tipecust}','#{sql_sales.namabrand}',
            '#{sql_sales.bonus}','#{sql_sales.groupcust}','#{sql_sales.plankinggroup}','#{Date.today}','#{sql_sales.tanggalinput}')")
          end
        end
      end
    end
  end

  def self.migration_sales_report_prev_month
    select("*").where("month(tanggalinput) = ?", 1.month.ago.month).each do |sql_sales|
      lapcab = LaporanCabang.find_by_nosj_and_kodebrg_and_bonus(sql_sales.nosj, sql_sales.kodebrg, sql_sales.bonus)
      if lapcab.nil?
        LaporanCabang.create(cabang_id: sql_sales.idcabang,
          nosj: sql_sales.nosj,
          tanggal: sql_sales.tanggalfaktur,
          tanggalsj: sql_sales.tanggalsj,
          nofaktur: sql_sales.nofaktur,
          noso: sql_sales.noso,
          nopo: sql_sales.nopo,
          kode_customer: sql_sales.kodecust,
          customer: sql_sales.customer,
          alamatkirim: sql_sales.alamatkirim,
          salesman: sql_sales.salesman,
          kodebrg: sql_sales.kodebrg,
          namabrg: sql_sales.namabrg,
          jenisbrgdisc: change_brand(sql_sales.jenisbrgdisc),
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
          tipecust: sql_sales.tipecust,
          namabrand: sql_sales.namabrand,
          bonus: sql_sales.bonus,
          groupcust: sql_sales.groupcust,
          plankinggroup: sql_sales.plankinggroup,
          tanggal_fetched: Date.today,
          tanggal_upload: sql_sales.tanggalinput
        )
      elsif (lapcab.nosj == sql_sales.nosj) && (lapcab.tanggal_upload.to_formatted_s(:short) != sql_sales.tanggalinput.to_formatted_s(:short))
        lapcab.update_attributes!(
          nofaktur: sql_sales.nofaktur,
          jenisbrgdisc: change_brand(sql_sales.jenisbrgdisc),
          kodejenis: sql_sales.kodejenis,
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
          bonus: sql_sales.bonus,
          tanggal_upload: sql_sales.tanggalinput)
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

  def self.migration_sales_report_by_branch(month, year, branch)
    select("*").where("idcabang = ? and month(tanggalsj) = ? and year(tanggalsj) = ?", branch, month, year).each do |sales|
      lapcab = LaporanCabang.find_by_tanggalsj_and_nosj_and_kodebrg_and_customer_and_bonus(sales.tanggalsj,
        sales.nosj, sales.kodebrg, sales.customer, sales.bonus)
      if lapcab.nil?
        LaporanCabang.create!(cabang_id: sales.idcabang,
          nosj: sales.nosj,
          tanggal: sales.tanggalfaktur,
          tanggalsj: sales.tanggalsj,
          nofaktur: sales.nofaktur,
          noso: sales.noso,
          nopo: sales.nopo,
          kode_customer: sales.kodecust,
          customer: sales.customer,
          alamatkirim: sales.alamatkirim,
          salesman: sales.salesman,
          kodebrg: sales.kodebrg,
          namabrg: sales.namabrg,
          jenisbrgdisc: sales.jenisbrgdisc,
          kodejenis: sales.kodejenis,
          jenisbrg: sales.jenisbrg,
          kodeartikel: sales.kodeartikel,
          namaartikel: sales.namaartikel,
          kodekain: sales.kodekain,
          namakain: sales.namakain,
          panjang: sales.panjang,
          lebar: sales.lebar,
          jumlah: sales.jumlah,
          satuan: sales.satuan,
          hargasatuan: sales.hargasatuan,
          hargabruto: sales.hargabruto,
          diskon1: sales.diskon1,
          diskon2: sales.diskon2,
          diskon3: sales.diskon3,
          diskon4: sales.diskon4,
          diskon5: sales.diskon5,
          diskonsum: sales.diskonsum,
          diskonrp: sales.diskonrp,
          harganetto1: sales.harganetto1,
          harganetto2: sales.harganetto2,
          totalnetto1: sales.totalnetto1,
          totalnetto2: sales.totalnetto2,
          totalnettofaktur: sales.totalnettofaktur,
          cashback: sales.cashback,
          nupgrade: sales.nupgrade,
          ketppb: sales.ketppb,
          kota: sales.kota,
          tipecust: sales.tipecust,
          namabrand: sales.namabrand,
          bonus: sales.bonus,
          groupcust: sales.groupcust,
          plankinggroup: sales.plankinggroup,
          tanggal_fetched: Date.today,
          tanggal_upload: sales.tanggalinput
        )
      else
        lapcab.update_attributes!(
          jenisbrgdisc: sales.jenisbrgdisc,
          kodejenis: sales.kodejenis,
          jumlah: sales.jumlah,
          satuan: sales.satuan,
          hargasatuan: sales.hargasatuan,
          hargabruto: sales.hargabruto,
          diskon1: sales.diskon1,
          diskon2: sales.diskon2,
          diskon3: sales.diskon3,
          diskon4: sales.diskon4,
          diskon5: sales.diskon5,
          diskonsum: sales.diskonsum,
          diskonrp: sales.diskonrp,
          harganetto1: sales.harganetto1,
          harganetto2: sales.harganetto2,
          totalnetto1: sales.totalnetto1,
          totalnetto2: sales.totalnetto2,
          totalnettofaktur: sales.totalnettofaktur,
          cashback: sales.cashback,
          nupgrade: sales.nupgrade,
          bonus: sales.bonus,
          tanggal_upload: sales.tanggalinput)
      end
    end
  end
end