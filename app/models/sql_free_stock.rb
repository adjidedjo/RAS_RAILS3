class SqlFreeStock < ActiveRecord::Base
  establish_connection "sqlserver"
  set_table_name "TbStockCabang"

  def self.migration_stok
    Stock.auto_stock_jde
    where("tanggal >= ?", Date.today).each do |sql_stock|
      fstock = Stock.where(cabang_id: sql_stock.cabang, kodebrg: sql_stock.kodebrg)
      if fstock.empty?
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
      else
        fstock.first.update_attributes!(
          tanggal: sql_stock.tanggal,
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
