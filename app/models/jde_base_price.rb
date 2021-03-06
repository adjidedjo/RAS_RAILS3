class JdeBasePrice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4106"
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
        REGEXP_LIKE(bpmcu,'11002|11011|13011|11012|12111|12112|13111|11091|11092|13091|11081|11082|13081')
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
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" #pusat
      "01"
    elsif bu == "11101" || bu == "11102" || bu == "11101C" || bu == "11101D" || bu == "11101S" || bu == "18101" || bu == "18101C" || bu == "18101D" || bu == "18102" || bu == "18101S" || bu == "18101K" #lampung
      "13" 
    elsif bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18012" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" #surabaya
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "12111C" || bu == "12111D" || bu == "12111S" || bu == "18111" || bu == "18111C" || bu == "18111D" || bu == "18112" || bu == "18111S" || bu == "18111K" || bu == "18112C" || bu == "18112D" || bu == "18112K" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "12071C" || bu == "12071D" || bu == "12071S" || bu == "18071" || bu == "18071C" || bu == "18071D" || bu == "18072" || bu == "18071S" || bu == "18071K" || bu == "18072C" || bu == "18071D" || bu == "18071K" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "12131C" || bu == "12131D" || bu == "12131S" || bu == "18131" || bu == "18131C" || bu == "18131D" || bu == "18132" || bu == "18131S" || bu == "18131K" || bu == "18132C" || bu == "18132D" || bu == "18132K" #jember
      "22" 
    elsif bu == "11091" || bu == "11092" || bu == "11091C" || bu == "11091D" || bu == "11091S" || bu == "18091" || bu == "18091C" || bu == "18091D" || bu == "18092" || bu == "18091S" || bu == "18091K" || bu == "18092C" || bu == "18092D" || bu == "18092K" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "11041C" || bu == "11041D" || bu == "11041S" || bu == "18041" || bu == "18041C" || bu == "18041D" || bu == "18042" || bu == "18042S" || bu == "18042K" || bu == "18042C" || bu == "18042D" || bu == "18042K" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "11051C" || bu == "11051D" || bu == "11051S" || bu == "18051" || bu == "18051C" || bu == "18051D" || bu == "18052" || bu == "18051S" || bu == "18051K" || bu == "18052C" || bu == "18052D" || bu == "18052K" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "11081C" || bu == "11081D" || bu == "11081S" || bu == "18081" || bu == "18081C" || bu == "18081D" || bu == "18082" || bu == "18081S" || bu == "18081K" || bu == "18082C" || bu == "18082D" || bu == "18082K" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "11121C" || bu == "11121D" || bu == "11121S" || bu == "18121" || bu == "18121C" || bu == "18121D" || bu == "18122" || bu == "18121S" || bu == "18121K" || bu == "18122C" || bu == "18122D" || bu == "18122K" #pekanbaru
      "20"
    elsif bu.include?('180120') || bu.include?("180110") #tasikmalaya
      "2"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    elsif bu == "1206104" || bu == "1206204" || bu == "1206104C" || bu == "1206104D" || bu == "1206104S" || bu == "1806104" || bu == "1806104" || bu == "1806104C" || bu == "1806104D" || bu == "1806104S" || bu == "1806204D" || bu == "1806204" || bu == "1806204K" #kediri
      "54"
    end
  end
end
