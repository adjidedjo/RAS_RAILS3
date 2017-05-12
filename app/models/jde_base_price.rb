class JdeBasePrice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4106"
  #bp
  def self.harga_satuan(item, branch_plant, order_date)
    harga = where("bpitm = ? and bpmcu like ? and bpexdj >= ?", item, "%#{branch_plant}", order_date)
    if harga.nil? || harga.empty?
    0
    else
    harga.first.bpuprc
    end
  end

  def self.import_base_price
    prices = find_by_sql("
      SELECT BP.bplitm, BP.bpmcu, IM.imdsc1, IM.imdsc2, IM.imsrp1, IM.imsrp2, BP.bpuprc, IM.imseg4 FROM
      (
        SELECT DISTINCT MAX(bplitm) AS bplitm, bpitm, bpmcu, MAX(bpuprc) AS bpuprc,
        MAX(bpeftj) AS bpeftj, MAX(bpexdj) AS bpexdj FROM PRODDTA.F4106
        WHERE LENGTH(TRIM(TRANSLATE(bpmcu, ' +-.0123456789',' '))) IS NULL AND
        REGEXP_LIKE(bplitm,'KM|HB|DV|SA|SB|ST|KB') AND 
        REGEXP_LIKE(bplitm,'11002|11011|13011|11012|12111|12112|13111|11091|11092|13091|11081|11082|13081')
        GROUP BY bpitm, bpmcu ORDER BY bpexdj, bpeftj DESC
      ) BP
      LEFT JOIN
      (
        SELECT imitm, MAX(imdsc1) AS imdsc1, MAX(imdsc2) AS imdsc2, MAX(imsrp1) AS imsrp1,
        MAX(imsrp2) AS imsrp2, MAX(imlitm) AS imlitm, MAX(imseg4) AS imseg4
        FROM PRODDTA.F4101 WHERE imtmpl LIKE '%BJ MATRASS%'
        AND REGEXP_LIKE(imsrp2,'KM|HB|DV|SA|SB|ST|KB')
        GROUP BY imitm
      ) IM ON BP.bpitm = IM.imitm
    ")
    prices.each do |pr|
      unless pr.imseg4.nil? || pr.imseg4.strip == 'K' || pr.imseg4.strip == 'T'
        checking = BasePrice.where("item_number LIKE '#{pr.bplitm.strip}' AND branch = '#{pr.bpmcu.strip}'")
        unless checking.present?
          description = pr.imdsc1.nil? ? '-' : (pr.imdsc1.strip+' '+pr.imdsc2.strip)
          branch = jde_cabang(pr.bpmcu.strip)
          ActiveRecord::Base.connection.execute("INSERT INTO base_prices
            (item_number, description, base_price, branch, brand, product)
            VALUES ('#{pr.bplitm.strip}', '#{description}', '#{pr.bpuprc.to_i/10000}', '#{branch}',
            '#{jde_brand(pr.imsrp1.strip)}', '#{pr.imsrp2}')
          ")
        else
          ActiveRecord::Base.connection.execute("UPDATE base_prices
            SET base_price = '#{pr.bpuprc.to_i/10000}' WHERE item_number = '#{pr.bplitm.strip}' AND
            branch = '#{branch}'
          ")
        end
      end
    end
  end

private

  def self.jde_brand(br)
    if br == 'E'
      'ELITE'
    elsif br == 'L'
      'LADY'
    elsif br == 'S'
      'SERENITY'
    elsif br == 'R'
      'ROYAL FOAM'
    elsif br == 'C'
      'CLASSIC'
    elsif br == 'G'
      'GRAND'
    else
      '-'
    end
  end

  def self.jde_cabang(bu)
    if bu == "11001" #pusat
      "01"
    elsif bu == "11011" || bu == "11012" || bu == "11011C" || bu == "11011D" || bu == "11002" #jabar
      "02"
    elsif bu == "11021" || bu == "11022" || bu == "13021" || bu == "13021D" || bu == "13021C" || bu == "11021C" || bu == "11021D" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "13061"|| bu == "13001" || bu == "13061C" || bu == "13061D" #surabay
      "07"
    elsif bu == "11151" || bu == "11152" || bu == "13151" || bu == "13151C" || bu == "13151D" || bu == "11151C" || bu == "11151D" #cikupa
      "23"
    elsif bu == "11031" || bu == "11032" || bu == "11031C" || bu == "11031D" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "13111" || bu == "12111C" || bu == "12111D" || bu == "13111C" || bu == "13111D" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "13071" || bu == "12071C" || bu == "12071D" || bu == "13071C" || bu == "13071D" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "13131" || bu == "12131C" || bu == "12131D" || bu == "13131C" || bu == "13131D" #jember
      "22"
    elsif bu == "11101" || bu == "11102" || bu == "13101" || bu == "11101C" || bu == "11101D" || bu == "13101C" || bu == "13101D" #lampung
      "13"  
    elsif bu == "11091" || bu == "11092" || bu == "13091" || bu == "11091C" || bu == "11091D" || bu == "13091C" || bu == "13091D" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "13041" || bu == "11041C" || bu == "11041D" || bu == "13041C" || bu == "13041D" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "13051" || bu == "11051C" || bu == "11051D" || bu == "13051C" || bu == "13051D" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "13081" || bu == "11081C" || bu == "11081D" || bu == "13081C" || bu == "13081D" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "13121" || bu == "11121C" || bu == "11121D" || bu == "13121C" || bu == "13121D" #pekanbaru
      "20"
    end
  end
end
