class Production < JdeSoDetail

  #import oustanding order for planning production
  def self.production_import_outstanding_orders
    outstanding = find_by_sql("SELECT so.sddoco, MAX(so.sddrqj) AS sddrqj, 
    SUM(so.sduorg) AS jumlah, MAX(so.sdtrdj) AS sdtrdj,
    MAX(so.sdsrp1) AS sdsrp1, MAX(so.sdmcu) AS sdmcu, so.sditm, MAX(so.sdlitm) AS sdlitm, 
    MAX(so.sddsc1) AS sddsc1, MAX(so.sddsc2) AS sddsc2, MAX(itm.imseg1) AS imseg1
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE so.sdcomm NOT LIKE '%#{'K'}%' AND so.sdtrdj = '#{date_to_julian(Date.yesterday)}'
    AND REGEXP_LIKE(so.sddcto,'SO|ZO|ST') AND itm.imtmpl LIKE '%BJ MATRASS%' AND
    so.sdnxtr <= '560' AND REGEXP_LIKE(so.sdmcu,'11001$|11002$')
    GROUP BY so.sddoco, so.sditm")
    Pdc::OutstandingOrder.delete_all
    outstanding.each do |ou|
      op = Pdc::OutstandingProduction.find_by_short_item_and_branch(ou.sditm.to_i, ou.sdmcu.strip)
      item_master = JdeItemMaster.get_item_number(ou.sditm.to_i)
      unless op
        Pdc::OutstandingProduction.create!(short_item: ou.sditm.to_i, 
        description: ou.sddsc1.strip + ' ' + ou.sddsc2.strip, brand: ou.sdsrp1.strip, branch: ou.sdmcu.strip, 
        item_number: ou.sdlitm.strip, segment1: ou.imseg1.strip)
      end
      Pdc::OutstandingOrder.create(order_no: ou. sddoco.to_i, 
      promised_delivery: julian_to_date(ou.sddrqj), branch: ou.sdmcu.strip, 
      brand: ou.sdsrp1.strip, item_number: ou.sdlitm.strip, description: ou.sddsc1.strip + ' ' + ou.sddsc2.strip,
      order_date: julian_to_date(ou.sdtrdj), quantity: ou.jumlah/10000, short_item: ou.sditm.to_i, segment1: ou.imseg1.strip)
    end
  end

  #import sales orders for planning production more than 3 months ago
  def self.production_import_sales_orders
    outstanding = find_by_sql("SELECT MAX(so.sddrqj), 
    SUM(so.sduorg) AS jumlah, MAX(so.sdtrdj) AS sdtrdj,
    MAX(so.sdsrp1) AS sdsrp1, so.sdmcu, so.sditm, MAX(so.sdlitm) AS sdlitm, 
    MAX(so.sddsc1) AS sddsc1, MAX(so.sddsc2) AS sddsc2, MAX(itm.imseg1) AS imseg1
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE so.sdcomm NOT LIKE '%#{'K'}%' AND so.sdtrdj BETWEEN '#{date_to_julian(3.months.ago.beginning_of_month.to_date)}' 
    AND '#{date_to_julian(Date.today.to_date)}' AND itm.imtmpl LIKE '%BJ MATRASS%'
    AND REGEXP_LIKE(so.sddcto,'SO|ZO|ST') AND 
    so.sdlttr NOT LIKE '%#{980}%' AND REGEXP_LIKE(so.sdmcu,'11001$|11002$')
    GROUP BY so.sdmcu, so.sditm")
    Pdc::SalesOrder.delete_all
    outstanding.each do |ou|
      op = Pdc::OutstandingProduction.find_by_short_item_and_branch(ou.sditm.to_i, ou.sdmcu.strip)
      unless op
        Pdc::OutstandingProduction.create!(short_item: ou.sditm.to_i, 
        description: ou.sddsc1.strip + ' ' + ou.sddsc2.strip, brand: ou.sdsrp1.strip, branch: ou.sdmcu.strip, 
        item_number: ou.sdlitm.strip, segment1: ou.imseg1.strip)
      end
      Pdc::SalesOrder.create(branch: ou.sdmcu.strip, brand: ou.sdsrp1.strip, 
      item_number: ou.sdlitm.strip, description: ou.sddsc1.strip + ' ' + ou.sddsc2.strip, 
      quantity: ou.jumlah/10000, short_item: ou.sditm.to_i)
    end
  end
  
  #import stock hourly for planning production
  def self.production_import_stock_hourly
    stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
    IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
    FROM PRODDTA.F41021 IA WHERE NOT REGEXP_LIKE(liglpt, 'WIP|MAT') 
    AND REGEXP_LIKE(limcu,'11001$|11001DH$|11001MT$') 
    AND IA.lipqoh >= 1 GROUP BY IA.liitm, IA.limcu")
    Pdc::ProductionStock.delete_all
    stock.each do |st|
      item_master = ItemMaster.find_by_short_item_no(st.liitm)
      jdbuffer = self.find_by_sql("SELECT MAX(IB.ibsafe) AS ibsafe
        FROM PRODDTA.F4102 IB WHERE IB.ibitm = '#{st.liitm}'")
      unless item_master.nil?
        status = /\A\d+\z/ === st.limcu.strip.last ? 'FG' : 'CP'
        description = item_master.desc+' '+item_master.desc2
        Pdc::ProductionStock.create(branch: st.limcu.strip, brand: item_master.slscd1, description: description,
          item_number: item_master.item_number, onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000, 
          status: status, product: item_master.segment2, short_item: item_master.short_item_no, 
          buffer: jdbuffer.first.ibsafe/10000)
      end
    end
  end
end