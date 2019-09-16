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
       GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_week, fiscal_month, fiscal_year, updated_at, city)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), fiscal_month, fiscal_year, NOW(), kota
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.SH2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('DIRECT', 'SHOWROOM')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM1BRAND (fiscal_day, fiscal_month, fiscal_year, branch, brand, sales_quantity, sales_amount, updated_at, DATE, WEEK)
       SELECT DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, SUM(jumlah), SUM(harganetto2), NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}'
       GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_week, fiscal_month, fiscal_year, updated_at, city)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), fiscal_month, fiscal_year, NOW(), kota
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.MM2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
       fiscal_day, fiscal_month, fiscal_year, updated_at, DATE, WEEK)
       SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), tanggalsj, WEEK
       FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust IN ('MODERN')
       AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")
  end

  def self.calculate_rkm
    ActiveRecord::Base.connection.execute("
      INSERT INTO rkm_histories(branch, address_number, sales_name, WEEK, YEAR, item_number, size, brand, segment2_name,
        segment3_name, quantity)
        SELECT * FROM (
          SELECT f1.branch, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS WEEK,
              IFNULL(fw.year, tl.fiscal_year) AS YEAR, f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
              IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
              GREATEST(GREATEST(IFNULL(fw.quantity, 0) - IFNULL(tl.jumlah,0),0) + IFNULL(rh.quantity,0),0) FROM
              (
                SELECT item_number, address_number, branch FROM forecast_weeklies WHERE WEEK = '#{1.week.ago.to_date.cweek}' AND YEAR = '#{1.week.ago.to_date.year}'
                GROUP BY address_number, item_number, branch

                UNION

                SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
                WHERE tanggalsj BETWEEN '#{1.week.ago.beginning_of_week.to_date}' AND '#{1.week.ago.end_of_week.to_date}' AND nopo IS NOT NULL
                AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO') GROUP BY area_id, kodebrg, nopo
              ) f1
              LEFT JOIN
              (
                SELECT * FROM forecast_weeklies WHERE WEEK = '#{1.week.ago.to_date.cweek}' AND YEAR = '#{1.week.ago.to_date.year}' GROUP BY branch, brand, address_number, item_number
              ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
              LEFT JOIN
              (
                SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK, fiscal_year
                FROM dbmarketing.tblaporancabang
                WHERE tanggalsj BETWEEN '#{1.week.ago.beginning_of_week.to_date}' AND '#{1.week.ago.end_of_week.to_date}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')
                AND ketppb NOT LIKE '%D'
                GROUP BY area_id, kodebrg, nopo
              ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
              LEFT JOIN
              (
                SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE WEEK = '#{2.week.ago.to_date.cweek}' AND YEAR = '#{2.week.ago.to_date.year}'
              ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
              LEFT JOIN
              (
                SELECT * FROM dbmarketing.tbidcabang
              ) cab ON cab.id = f1.branch
              ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
        ) au
        WHERE au.week IS NOT null
    ")
  end
end