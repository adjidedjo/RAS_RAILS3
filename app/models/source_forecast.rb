class SourceForecast < ActiveRecord::Base
    establish_connection "sales-mart"
    self.table_name = "DETAIL_SALES_FOR_FORECASTS" #rp

    def self.insert_into_table(invoicedate, fmonth, fweek, year, cabang_id, rpdoc, branch,
        kodesales, namasales, tipecust, item_number, tipe, article, kain, panjang, 
        lebar, group_forecast, jumlah, dsc1, dsc2)
        description = ((dsc1.nil? ? '' : dsc1.strip) + ' ' + (dsc2.nil? ? '' : dsc2.strip))
        find_area = ActiveRecord::Base.connection.execute("SELECT area_id FROM dbmarketing.gudangs WHERE code = '#{cabang_id}'")
        area_id = find_area.first.nil? ? branch : find_area.first[0]
	bom = ActiveRecord::Base.connection.execute("SELECT bom_id, bom_name FROM sales_mart.branch_of_manager WHERE sales_id = '#{kodesales}'")
        bom_id = bom.first.nil? ? '' : bom.first[0]
        bom_name = bom.first.nil? ? '' : bom.first[1]
        ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.DETAIL_SALES_FOR_FORECASTS (nopo, salesman, 
            item_number, brand, segment1_code, segment2_code, segment3_code, panjang, lebar, 
            product_name, area_id, customer_type, invoice_date, month, year, week, total, bp, bom, bom_name)
            VALUES ('#{kodesales}', '#{namasales}', 
                '#{item_number}', '#{group_forecast}', '#{tipe.strip}', '#{article.strip}', '#{kain}', '#{panjang.strip}', '#{lebar.strip}', 
                '#{description}', '#{area_id}', '#{tipecust}', '#{invoicedate}', '#{fmonth}', '#{year}', '#{fweek}', '#{jumlah}', 
                #{cabang_id}, '#{bom_id}', '#{bom_name}') ")                
    end
end
