class SqlFreeStock < ActiveRecord::Base
  establish_connection "sqlserver"
  set_table_name "TbStockCabang"

  def self.migration_stok(bulan, tahun)
    where("month(tanggal) = ? and year(tanggal) = ?", bulan, tahun).each do |sql_stock|
      free_stock = Stock.find_by_tanggal_and_cabang_id_and_kodebrg(sql_stock.tanggal, sql_stock.cabang, sql_stock.kodebrg)
      if free_stock.nil?
        Stock.create(
          tanggal: sql_stock.tanggal,
          cabang_id: sql_stock.cabang,
          kodebrg: sql_stock.kodebrg,
          namabrg: sql_stock.namabrg,
          freestock: sql_stock.freestock,
          bufferstock: sql_stock.bufferstock,
          outstandingSO: sql_stock.outstandingSO,
          outstandingPBJ: sql_stock.outstandingPBJ,
          realstock: sql_stock.realstock,
          realstockservice: sql_stock.realstockservice,
          realstockdowngrade: sql_stock.realstockdowngrade
        )
      end
    end
  end
end
