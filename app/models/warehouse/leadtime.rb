class Warehouse::Leadtime < ActiveRecord::Base
  establish_connection "warehouse"
  self.table_name = "LEADTIMES"
  
  def self.calculate_leadtime
    ActiveRecord::Base.connection.execute("TRUNCATE warehouse.LEADTIMES")
    lead = ActiveRecord::Base.establish_connection("jdeoracle").connection.execute("
    SELECT LEDGER.FROM_BP, LEDGER.TO_BP, LEDGER.SHORT_I, MAX(SO.SDLITM) AS ITEM_NUMBER, MAX(SO.SDDSC1) AS DESC1, 
    MAX(SO.SDITM), LEDGER.ILCRDJ AS RECEIPT, MAX(SO.SDDRQJ) AS REQ, MAX(SO.SDADDJ) AS ACTUAL_SHIP,
    MAX(SO.SDOPDJ) AS PROMISE_DATE, MAX(SO.SDTRDJ) AS ORDER_DATE FROM
    (
     SELECT LEDGER.ILMCU AS TO_BP, LEDGER.ILAN8 AS FROM_BP, LEDGER.ILITM AS SHORT_I, LEDGER.ILDOCO, LEDGER.ILDCTO, 
     LEDGER.ILCRDJ
     FROM PRODDTA.F4111 LEDGER WHERE LEDGER.ILCRDJ BETWEEN '#{date_to_julian(3.months.ago.to_date)}' AND 
     '#{date_to_julian(Date.today.to_date)}' AND LEDGER.ILDCTO IN ('OK', 'OT') AND LEDGER.ILAN8 > 0 
     AND LEDGER.ILDCT IN ('OV', 'VT') AND 
     REGEXP_LIKE(LEDGER.ILAN8, '11001$|11002$|12002$|12001$|15001$|15002$|15151$
     |15152$|11051$|11052$|11081$|11082$|11091$|11092$')
     GROUP BY LEDGER.ILITM, LEDGER.ILDOCO, LEDGER.ILDCTO, LEDGER.ILCRDJ, LEDGER.ILAN8, LEDGER.ILMCU
    ) LEDGER
    LEFT JOIN 
    (
      SELECT * FROM PRODDTA.F4211
    ) SO ON LEDGER.ILDCTO = SO.SDRCTO AND TO_NUMBER(LEDGER.ILDOCO) = SO.SDRORN AND LEDGER.SHORT_I = SO.SDITM
    LEFT JOIN 
    (
      SELECT * FROM PRODDTA.F0006 WHERE MCRP05 = '501'
    ) BP ON LEDGER.TO_BP = BP.MCMCU
    GROUP BY LEDGER.FROM_BP, LEDGER.TO_BP, LEDGER.SHORT_I, LEDGER.ILCRDJ")
    while r = lead.fetch_hash
       self.create(short_item: r["SHORT_I"].to_i, 
       item_number: r["ITEM_NUMBER"].nil? ? '-' : r["ITEM_NUMBER"].strip, 
       description: r["DESC1"].nil? ? '-' : r["DESC1"].strip,
       from_branch: r["FROM_BP"].to_i, to_branch: r["TO_BP"].to_i, 
       fulfillment_day: (r["RECEIPT"].to_i - r["ORDER_DATE"].to_i), 
       actual_ship: (r["RECEIPT"].to_i - r["ACTUAL_SHIP"].to_i),
       promise_date: (r["RECEIPT"].to_i - r["PROMISE_DATE"].to_i))
    end
  end

  private
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
end