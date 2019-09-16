class BatchToMart < ActiveRecord::Base
  
  def self.batch_transform_retail(month, year)
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1BRAND (fiscal_day, fiscal_month, fiscal_year, branch, brand, sales_quantity, sales_amount, updated_at, date, week)
      SELECT DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, SUM(jumlah), SUM(harganetto2), NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' 
            GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;")
            
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;")
    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_week, fiscal_month, fiscal_year, updated_at, city)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), fiscal_month, fiscal_year, NOW(), kota
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALBRAND (branch, brand, salesmen, salesmen_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, nopo, salesman, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALPRODUCT (branch, brand, salesmen, salesmen_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, nopo, salesman, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM warehouse.F03B11_INVOICES WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALARTICLE (branch, brand, salesmen, salesmen_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, nopo, salesman, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYBRAND (branch, brand, city, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kota, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYPRODUCT (branch, brand, city, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kota, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYARTICLE (branch, brand, city, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at, date, week)
      SELECT area_id, jenisbrgdisc, kota, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, week
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' 
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")
  end
  
  def self.batch_transform_direct(month, year)
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH1BRAND (fiscal_day, fiscal_month, fiscal_year, branch, brand, sales_quantity, sales_amount, updated_at, DATE, WEEK)
       SELECT DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, SUM(jumlah), SUM(harganetto2), NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' 
       GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;
       
      REPLACE INTO sales_mart.SH1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;
       
      REPLACE INTO sales_mart.SH1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;
       
      REPLACE INTO sales_mart.SH2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_week, fiscal_month, fiscal_year, updated_at, city)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), fiscal_month, fiscal_year, NOW(), kota
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;
       
      REPLACE INTO sales_mart.SH2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;
       
      REPLACE INTO sales_mart.SH2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;
       
      REPLACE INTO sales_mart.MM1BRAND (fiscal_day, fiscal_month, fiscal_year, branch, brand, sales_quantity, sales_amount, updated_at, DATE, WEEK)
       SELECT DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, SUM(jumlah), SUM(harganetto2), NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' 
       GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;
       
      REPLACE INTO sales_mart.MM1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;
       
      REPLACE INTO sales_mart.MM1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;
       
      REPLACE INTO sales_mart.MM2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_week, fiscal_month, fiscal_year, updated_at, city)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), fiscal_month, fiscal_year, NOW(), kota
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;
       
      REPLACE INTO sales_mart.MM2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;
       
      REPLACE INTO sales_mart.MM2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;  
      ")
  end
  
end