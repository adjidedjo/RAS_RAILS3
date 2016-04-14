class JdeItemMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4101" #im

  scope :include_items, -> { where("imprgr in (?) and imdsc1 not like ?", ['ELITE', 'LADY', 'PURECARE', 'TECHGEL'], '%HOTEL%')}

  def self.get_item_number(short_item)
    where(imitm: short_item)
  end

  def self.get_new_items_from_jde
    where("imtmpl like ? and imseg4 = ? and imupmj like ?", "%BJ MATRASS%", "S", date_to_julian(Date.yesterday.to_date)).include_items.each do |imjde|
      pim = PosItemMaster.where("kode_barang like ?", imjde.imaitm.strip)
      if pim.empty?
        nama_brg = imjde.imdsc1.strip + " " + imjde.imdsc2.strip
        PosItemMaster.create(kode_barang: imjde.imaitm.strip, nama: nama_brg, brand_id: brand(imjde.imprgr.strip), jenis: imjde.imseg1.strip, harga: 0)
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
