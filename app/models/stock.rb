class Stock < ActiveRecord::Base
  
  def self.update_area_id
    self.where(status: 'N').each do |stock|
      stock.update_attributes!(area_id: jde_cabang(stock.branch))
    end
  end

  def self.jde_cabang(bu)
    if bu == "11001" || bu == "11001D" || bu == "11001C" #pusat
      "01"
    elsif bu.include?("1110") || bu == "11101" || bu == "11102" || bu == "13101" || bu == "11101C" || bu == "11101D" || bu == "13101C" || bu == "13101D" || bu == "11101S" || bu == "13101S" #lampung
      "13" 
    elsif bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18002" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu.include?("1200") || bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu.include?("1206") || bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "13061"|| bu == "13001" || bu == "13061C" || bu == "13061D" || bu == "12061S" || bu == "13061S" #surabay
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" #cikupa
      "23"
    elsif bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu.include?("1311") || bu.include?("1211") || bu == "12111" || bu == "12112" || bu == "13111" || bu == "12111C" || bu == "12111D" || bu == "13111C" || bu == "13111D" || bu == "12111S" || bu == "13111S" #makasar
      "19"
    elsif bu.include?("1207") || bu == "12071" || bu == "12072" || bu == "13071" || bu == "12071C" || bu == "12071D" || bu == "13071C" || bu == "13071D" || bu == "12111S" || bu == "13071S" #bali
      "04"
    elsif bu.include?("1213") || bu == "12131" || bu == "12132" || bu == "13131" || bu == "12131C" || bu == "12131D" || bu == "13131C" || bu == "13131D" || bu == "12131S" || bu == "13131S" #jember
      "22" 
    elsif bu.include?("1109") || bu == "11091" || bu == "11092" || bu == "13091" || bu == "11091C" || bu == "11091D" || bu == "13091C" || bu == "13091D" || bu == "11091S" || bu == "13091S" #palembang
      "11"
    elsif bu.include?("1104") || bu == "11041" || bu == "11042" || bu == "13041" || bu == "11041C" || bu == "11041D" || bu == "13041C" || bu == "13041D" || bu == "11041S" || bu == "13041S"#yogyakarta
      "10"
    elsif bu.include?("1105") || bu == "11051" || bu == "11052" || bu == "13051" || bu == "11051C" || bu == "11051D" || bu == "13051C" || bu == "13051D" || bu == "11051S" || bu == "13051S" #semarang
      "08"
    elsif bu.include?("1108") || bu == "11081" || bu == "11082" || bu == "13081" || bu == "11081C" || bu == "11081D" || bu == "13081C" || bu == "13081D" || bu == "11081S" || bu == "13081S" #medan
      "05"
    elsif bu.include?("1112") || bu == "11121" || bu == "11122" || bu == "13121" || bu == "11121C" || bu == "11121D" || bu == "13121C" || bu == "13121D" || bu == "11121S" || bu == "13121S" #pekanbaru
      "20"
    end
  end
end
