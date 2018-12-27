class Production < JdeSoDetail

  #import oustanding order for planning production
  def self.production_import_outstanding_orders
    outstanding = Warehouse::F4211Order.find_by_sql("
    SELECT * FROM warehouse.F4211_ORDERS
    WHERE branch REGEXP '11001$|11002$|12001$|12002$|18081$|18082$|11081$|
    11082$|11091$|11092$|11051$|11052$|18091$|18092$|18051$|18052$|15151$|15152$'
    AND DATE(created_at) = '#{Date.today}'")
    Pdc::OutstandingOrder.delete_all
    outstanding.each do |ou|
      op = Pdc::OutstandingProduction.find_by_short_item_and_branch(ou.short_item, ou.branch)
      unless op
        Pdc::OutstandingProduction.create!(short_item: ou.short_item, 
        description: ou.description, brand: ou.brand, branch: ou.branch, 
        item_number: ou.item_number, segment1: ou.segment1)
      end
      Pdc::OutstandingOrder.create(order_no: ou.order_no, 
      promised_delivery: ou.promised_delivery, branch: ou.branch, 
      brand: ou.brand, item_number: ou.item_number, description: ou.description,
      order_date: ou.order_date, quantity: ou.quantity, short_item: ou.short_item, 
      segment1: ou.segment1, customer: ou.customer, ship_to: ou.ship_to, typ: ou.typ,
      last_status: ou.last_status, branch_desc: set_branch(ou.branch), originator: ou.originator,
      exceeds: (Date.today - ou.promised_delivery), next_status: ou.next_status, 
      day_category: category_days((Date.today - ou.promised_delivery)))
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
    AND REGEXP_LIKE(so.sddcto,'SO|ZO|ST|SK') AND 
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
    us = self.find_by_sql("SELECT IA.liitm AS liitm, 
    IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
    FROM PRODDTA.F41021 IA WHERE liupmj BETWEEN '#{date_to_julian(Date.yesterday)}' AND '#{date_to_julian(Date.today)}' AND  
    REGEXP_LIKE(limcu,'11001$|11001DH$|11001MT$') GROUP BY IA.liitm, IA.limcu")
    us.each do |fus|
      stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
      IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
      FROM PRODDTA.F41021 IA WHERE liitm = '#{fus.liitm}' AND limcu LIKE '%#{fus.limcu}' 
      GROUP BY IA.liitm, IA.limcu")
      stock.each do |st|
        cek_stock = Pdc::ProductionStock.where(short_item: st.liitm, branch: st.limcu.strip)
        st.update_attributes!(onhand: 0, available: 0) if stock.empty?
        jdbuffer = self.find_by_sql("SELECT MAX(IB.ibsafe) AS ibsafe
          FROM PRODDTA.F4102 IB WHERE IB.ibitm = '#{st.liitm}'")
        if cek_stock.present?
          cek_stock.first.update_attributes!(buffer: jdbuffer.first.ibsafe/10000,onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        elsif cek_stock.nil?
          item_master = ItemMaster.find_by_short_item_no(st.liitm)
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
  end
  
  def self.production_branch_order_and_buffer
    Pdc::BranchNeed.delete_all
    outstanding_pusat = Pdc::OutstandingOrder.find_by_sql("
      SELECT short_item, description, item_number, ship_to, branch, SUM(quantity) AS qty, brand, 
      segment1, customer FROM 
      outstanding_orders WHERE typ IN ('F', 'O') GROUP BY short_item, ship_to
    ")
    
    outstanding_pusat.each do |op|
      
      outstanding_cabang = find_by_sql("
          SELECT MAX(sddrqj) AS sddrqj, 
          SUM(sduorg) AS jumlah, MAX(sdmcu) AS sdmcu, sditm
          FROM PRODDTA.F4211 WHERE sdcomm NOT LIKE 'K'
          AND REGEXP_LIKE(sddcto, 'SO|ZO') AND sditm = '#{op.short_item}' AND sdmcu LIKE '%#{op.ship_to}'
          AND sdnxtr <= '560'
          GROUP BY sditm, sdmcu
        ")
        
      buffer_cabang = find_by_sql("
          SELECT MAX(ibsafe) AS ibsafe, MAX(ibmcu) AS ibmcu, MAX(ibitm) AS ibitm
          FROM PRODDTA.F4102 WHERE ibitm = '#{op.short_item}' AND ibmcu LIKE '%#{op.ship_to}'
        ")
        
       oh = Stock.find_by_sql("
          SELECT SUM(onhand) AS onhand FROM stocks WHERE short_item = '#{op.short_item}' AND 
          branch = '#{op.ship_to}' GROUP BY branch 
        ")
        
        Pdc::BranchNeed.create(item_number: op.item_number, qty_order: 
        (outstanding_cabang.first.nil? ? 0 : outstanding_cabang.first.jumlah/10000), segment1: op.segment1,
        short_item: op.short_item, item_number: op.item_number, description: op.description, brand: op.brand,
        branch: (outstanding_cabang.first.nil? ? op.ship_to : outstanding_cabang.first.sdmcu.strip), 
        qty_requested: op.qty, buffer: buffer_cabang.first.ibsafe.nil? ? 0 : buffer_cabang.first.ibsafe/10000, 
        onhand_branch: (oh.first.nil? ? 0 : oh.first.onhand), name: op.customer)
    end
  end
  
  def self.set_branch(mcu)
    if mcu =~ /^11001/ || mcu =~ /^11002/
      "bandung"
    elsif mcu =~ /^18081/ || mcu =~ /^18082/ || mcu =~ /^11081/ || mcu =~ /^11082/
      "medan"
    elsif mcu =~ /^18091/ || mcu =~ /^18092/ || mcu =~ /^11091/ || mcu =~ /^11092/
      "palembang"
    elsif mcu =~ /^18051/ || mcu =~ /^18052/ || mcu =~ /^11051/ || mcu =~ /^11052/
      "semarang"
    elsif mcu =~ /^12001/ || mcu =~ /^12002/
      "surabaya"
    elsif mcu =~ /^13151/ || mcu =~ /^11151/ || mcu =~ /^11152/ || mcu =~ /^1515^/
      "tangerang"
    end 
  end
  
  private
  
  def self.category_days(day)
    if day < 3
      3
    elsif day >= 3 && day < 5
      5
    elsif day >= 5 && day < 8
      8
    elsif day >= 8 && day < 15
      15
    elsif day >= 15 && day < 30
      30
    elsif day >= 30 && day < 60
      60
    elsif day >= 60
      61
    end
  end
end