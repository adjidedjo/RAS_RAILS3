class SourcePbj < ActiveRecord::Base
  establish_connection "sales-mart"

  def self.insert_into_table(tanggal, sdmcu, total_pbjm, total_pbjo, total_pbjm_amount, total_pbjo_amount,
	sdshan, des, kode_bp, brand)
    unless kode_bp.strip == "00"
      branch = ActiveRecord::Base.connection.execute("SELECT description, area_id FROM dbmarketing.gudangs WHERE code = '#{kode_bp}'")
      ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.ORDER_MANAGEMENTS (date, branch_plan, branch_id, branch, brand,
	  qty_pbjm, qty_pbjo, amount_pbjm, amount_pbjo)
            VALUES ('#{julian_to_date(tanggal)}', '#{sdmcu.strip}', '#{(branch.first.nil? ? '' : branch.first[1])}', 
            '#{(branch.first.nil? ? '' : branch.first[0])}', '#{brand.strip}', '#{total_pbjm}', '#{total_pbjo}', 
		'#{total_pbjm_amount}', '#{total_pbjo_amount}')")
    end               
  end

  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
end
