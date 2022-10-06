class Aging < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F41021" #rp

  def self.daily_aging_stock(date)
    aging = find_by_sql("SELECT LOT.LIITM, IM.IMLITM, IM.IMDSC1, IM.IMDSC2, IM.IMSRP1, LOT.LIMCU, BU.MCDL01, LOT.LILOTN, LOT.LIGLPT, LOT.LIPQOH, 
	LOT.LINCDJ AS AGING 
	FROM
	  (
  	    SELECT * FROM PRODDTA.F41021 WHERE LIPQOH >= 10000
          ) LOT 
        LEFT JOIN
         (
           SELECT * FROM PRODDTA.F4101
         ) IM ON IM.IMITM = LOT.LIITM AND IM.IMTMPL = 'BJ MATRASS'
        LEFT JOIN
         (
           SELECT * FROM PRODDTA.F0006
         ) BU ON BU.MCMCU LIKE ('%' || LOT.LIMCU || '%')")
    aging.each do |a|
      AgingStockDetail.create!(
        short_item: a.liitm,
        item_number: a.imlitm,
        description: a.imdsc1,
        brand: brand(a.imsrp1.nil? ? '-' : a.imsrp1.strip),
        branch_plan: a.limcu.strip,
        branch_plan_desc: a.mcdl01,
        lot_number: a.lilotn,
        glpt: a.liglpt,
        grouping: grouping(a.liglpt.strip),
        aging: cats((Date.today - JdeInvoice.julian_to_date(a.aging)).to_i),
        quantity: a.lipqoh/10000,
        cats: a.aging.to_i,
        created_at: Date.today
      )
    end 
  end

  def self.brand(b)
    if b == 'E'
      'ELITE'
    elsif b == 'L'
      'LADY'
    elsif b == 'S'
      'SERENITY'
    elsif b == 'R'
      'ROYAL'
    elsif b == 'O'
      'TOTE'
    elsif b == 'C'
      'CLASSIC'
    else
      b
    end
  end

  def self.grouping(glpt)
    if glpt == "EFE" || glpt == "ESE"|| glpt == "LFL"|| glpt == "LQL"|| glpt == "LSL" || glpt == "LVL"
      grp = "Bed Sheet"
    elsif glpt == "LNL" || glpt == "ONO"
      grp = "Bench"
    elsif glpt == "DVB" || glpt == "DVC"|| glpt == "DVE"|| glpt == "DVL"|| glpt == "DVO" || glpt == "DVS"
      grp = "Divan"
    elsif glpt == "HBB" || glpt == "HBC"|| glpt == "HBE"|| glpt == "HBL"|| glpt == "HBS"
      grp = "Headboard"
    elsif glpt == "KB" || glpt == "KBR"
      grp = "Kasur Busa"
    elsif glpt == "KMB" || glpt == "KMC"|| glpt == "KME"|| glpt == "KMG" || glpt == "KML" || glpt == "KMO" || glpt == "KMS" || glpt == "KMX"
      grp = "Matress"
    elsif glpt == "MOR"
      grp = "Moro"
    elsif glpt == "SFR"
      grp = "Sofabed"
    elsif glpt == "SAC" || glpt == "SAE"|| glpt == "SAL"|| glpt == "SAS" || glpt == "SBC" || glpt == "SBE" || glpt == "SBL" || glpt == "SBS" || glpt == "STE" || glpt == "STL" || glpt == "STS"
      grp = "Sorong"
    else
      "Accessories"
    end
  end

  def self.category(days)
    if days <= 60
      dys = "1-2"
    elsif days > 60 && days <= 120
      dys = "2-4"
    elsif days > 120 && days <= 180
      dys = "4-6"
    elsif days > 180 && days <= 365
      dys = "6-12"
    elsif days > 365 && days <= 730
      dys = "12-24"
    elsif days > 730
      dys = ">730"
    else 0
    end
  end

end
