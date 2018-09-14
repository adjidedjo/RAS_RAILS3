class JdeItemMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4101" #im

  scope :include_items, -> { where("imprgr in (?) and imdsc1 not like ?", ['ELITE', 'LADY', 'PURECARE', 'TECHGEL'], '%HOTEL%')}

  def self.get_item_number(short_item)
    where(imitm: short_item)
  end
  
  def self.get_item_number_from_second(second_item)
    where("imlitm like '%#{second_item}%'").first
  end

  def self.update_second
    PosItemMaster.all.each do |pim|
      where("imlitm LIKE '%#{pim.kode_barang}%'").each do |imjde|
        pim.update_attributes!(jde_item_master: imjde.imaitm.strip)
      end
    end
  end
  

  def self.get_new_items_from_jde
    where("imtmpl like ? and imseg4 = ? and imupmj like ?", "%BJ MATRASS%", "S", date_to_julian(Date.yesterday.to_date)).include_items.each do |imjde|
      pim = PosItemMaster.where("kode_barang like ?", imjde.imaitm.strip)
      if pim.empty?
        nama_brg = imjde.imdsc1.strip + " " + imjde.imdsc2.strip
        PosItemMaster.create(kode_barang: imjde.imlitm.strip, nama: nama_brg, brand_id: brand(imjde.imprgr.strip), jenis: imjde.imseg1.strip, harga: 0)
      end
    end
  end
  
  def self.item_masters_fetch
    item_masters = find_by_sql("SELECT IMITM, IMLITM, IMDSC1, IMDSC2, IMSRP1, IMSRP3, IMSRP9, IMPRGR, IMTMPL, IMSEG1,
    IMSEG2, IMSEG3, IMSEG4, IMSEG5, IMSEG6, IMSEG7, IMSEG8, IMSEG9, IMSEG0 FROM PRODDTA.F4101 WHERE
    IMTMPL LIKE '%BJ MATRASS%' AND IMSEG4 LIKE '%S%' 
    AND IMUPMJ = '#{date_to_julian(Date.yesterday.to_date)}'")
    item_masters.each do |im|
      check_item = ItemMaster.find_by_short_item_no(im.imitm)
      if check_item.nil? || check_item.nil?
        ItemMaster.create(short_item_no: im.imitm.to_i, item_number: im.imlitm, desc: im.imdsc1.strip, 
        desc2: im.imdsc2.strip, slscd1: im.imsrp1, slscd2: im.imsrp3, catcd9: im.imsrp9, 
        group_brand: im.imprgr.strip, template: im.imtmpl, segment1: im.imseg1, segment2: im.imseg2, 
        segment3: im.imseg3, segment4: im.imseg4, segment5: im.imseg5, segment6: im.imseg6, 
        segment7: im.imseg7, segment8: im.imseg8, segment9: im.imseg9, segment10: im.imseg0)
      end
    end
  end

  def self.date_to_julian(date)
    date = date.to_date
    1000*(date.year-1900)+date.yday
  end

  def self.brand(brand)
    if brand == "ELITE"
      2
    elsif brand == "LADY"
      4
    elsif brand == "PURECARE"
      8
    elsif brand == "TECHGEL"
      7
    end
  end
end
