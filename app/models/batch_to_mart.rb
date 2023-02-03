class BatchToMart < ActiveRecord::Base
  def self.batch_transform_whs_datawarehouse(month, year)
    ActiveRecord::Base.connection.execute("
      REPLACE INTO foam_datawarehouse.WHS1BRAND (AREA, branch, cabang_id, brand, date, fiscal_day, fiscal_month, fiscal_year, sales_quantity, sales_amount, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, tanggalsj, DAY(tanggalsj), fiscal_month, fiscal_year, SUM(jumlah), SUM(harganetto2), NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO foam_datawarehouse.WHS1PRODUCT (AREA, branch, cabang_id, brand, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS1ARTICLE (AREA, branch, cabang_id, brand, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, date, fiscal_day, fiscal_month, fiscal_year, updated_at, salesmen, salesmen_desc, city)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), tanggalsj, DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), IFNULL(nopo,'-'), salesman, kota
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS2PARENTCUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at, salesmen, salesmen_desc, city)
      SELECT area_id, jenisbrgdisc, groupcust, plankinggroup, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), IFNULL(nopo,'-'), salesman, kota
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, groupcust, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS2CUSPRODUCT (AREA, branch, cabang_id, brand, customer, customer_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS2CUSARTICLE (AREA, branch, cabang_id, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS3SALBRAND (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS3SALPRODUCT (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS3SALARTICLE (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS4CITYBRAND (AREA, branch, cabang_id, brand, city, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS4CITYPRODUCT (AREA, branch, cabang_id, brand, city, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO foam_datawarehouse.WHS4CITYARTICLE (AREA, branch, cabang_id, brand, city, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'WHS'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")
  end

  def self.batch_transform_foam_datawarehouse(month, year)
    SalesWarehouse.connection.execute("
      REPLACE INTO foam_bybrands (channel, area_id, area_desc, branch_id, branch_desc, brand, subbrand, total_qty,
       kubikasi, total_sales, dday, dweek, dmonth, dyear, tanggalsj, created_at)
       SELECT tipecust, area_id, area_desc, cabang_id, cabang_desc, brand, subbrand, SUM(jumlah), SUM(kubikasi),
       SUM(harganetto2), DAY(tanggalsj), WEEK(tanggalsj), MONTH(tanggalsj), YEAR(tanggalsj), tanggalsj, NOW()
       FROM sales_warehouses WHERE fiscal_month = '#{month}' AND fiscal_year = '#{year}'
              GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, brand, tipecust;")

    SalesWarehouse.connection.execute("
      REPLACE INTO foam_bychannel (channel, area_id, area_desc,  branch_id, branch_desc, total_qty, kubikasi,
      total_sales, dday, dweek, dmonth, dyear, tanggalsj, created_at)
        SELECT tipecust, area_id, area_desc,  cabang_id, cabang_desc, SUM(jumlah), SUM(kubikasi), SUM(harganetto2),
        DAY(tanggalsj), WEEK(tanggalsj), MONTH(tanggalsj), YEAR(tanggalsj), tanggalsj, NOW()
              FROM sales_warehouses WHERE fiscal_month = '#{month}' AND fiscal_year = '#{year}'
              GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, tipecust;")

    SalesWarehouse.connection.execute("
      REPLACE INTO foam_bysubbrands (area_id, area_desc, branch_id, branch_desc, brand, subbrand, channel,
       total_qty, kubikasi, total_sales, dday, dweek, dmonth, dyear, tanggalsj, created_at)
       SELECT area_id, area_desc, cabang_id, cabang_desc, brand, subbrand, tipecust, SUM(jumlah), SUM(kubikasi), SUM(harganetto2),
       DAY(tanggalsj), WEEK(tanggalsj), MONTH(tanggalsj), YEAR(tanggalsj), tanggalsj, NOW()
       FROM sales_warehouses WHERE fiscal_month = '#{month}' AND fiscal_year = '#{year}'
              GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, subbrand, tipecust;")

    SalesWarehouse.connection.execute("
      REPLACE INTO foam_bycusbrands (area_id, area_desc, branch_id, branch_desc, brand, subbrand, customer_id,
       customer_desc, channel, kota, salesman, total_qty, kubikasi, total_sales, total_sales_usd, dday, dweek, dmonth, dyear, tanggalsj, created_at)
       SELECT area_id, area_desc, cabang_id, cabang_desc, brand, subbrand, kode_customer, customer, tipecust, kota, salesman,
       SUM(jumlah), SUM(kubikasi), SUM(harganetto2), SUM(hargausd),
       DAY(tanggalsj), WEEK(tanggalsj), MONTH(tanggalsj), YEAR(tanggalsj), tanggalsj, NOW()
       FROM sales_warehouses WHERE fiscal_month = '#{month}' AND fiscal_year = '#{year}'
                  GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, brand, customer;")
  end

  def self.calculate_rkm_weekly
    week = 1.week.ago.to_date.cweek
    week_year = 1.week.ago.to_date.year
    last_week = 2.week.ago.to_date.cweek
    last_week_year = 2.week.ago.to_date.year

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.WEEKLY_PLANS(AREA, address_number, sales_name, brand, target_penjualan, jumlah_penjualan, branch, total_target, remain, WEEK, YEAR)
      SELECT * FROM(
        SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name,
        IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
        IFNULL(SUM(fw.quantity), 0) AS target_penjualan, IFNULL(SUM(tl.jumlah),0) AS jumlah_penjualan,
        f1.branch, (IFNULL(SUM(fw.quantity), 0)+IFNULL(SUM(rh.quantity),0)) AS total_target, IFNULL(rh.quantity,0) AS sisa,
        IFNULL(tl.week, f1.week) AS WEEK, IFNULL(tl.year, f1.year) AS YEAR FROM
        (
          SELECT item_number, address_number, branch, WEEK, YEAR FROM dbmarketing.forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{week_year}'
          AND (CASE WHEN '' = '' THEN branch >= 0 ELSE branch = '' END)
          GROUP BY address_number, item_number, branch
          UNION
          SELECT DISTINCT(kodebrg), nopo, area_id, WEEK, fiscal_year AS YEAR FROM dbmarketing.tblaporancabang
          WHERE WEEK = '#{week}' AND fiscal_year = '#{week_year}' AND nopo IS NOT NULL AND area_id IS NOT NULL
          AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX') AND
          (CASE WHEN '' = '' THEN area_id >= 0 ELSE area_id = '' END)
          GROUP BY area_id, kodebrg, nopo
        ) f1
        LEFT JOIN
        (
          SELECT * FROM dbmarketing.forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{week_year}' AND
          (CASE WHEN '' = '' THEN branch >= 0 ELSE branch = '' END)
          GROUP BY branch, brand, address_number, item_number
        ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
        LEFT JOIN
        (
          SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK, fiscal_year AS YEAR
          FROM dbmarketing.tblaporancabang
          WHERE WEEK = '#{week}' AND fiscal_year = '#{week_year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
          AND ketppb NOT LIKE '%D' AND nopo IS NOT NULL AND area_id IS NOT NULL
          GROUP BY area_id, kodebrg, nopo
        ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
        LEFT JOIN
        (
          SELECT item_number, address_number, WEEK, quantity FROM dbmarketing.rkm_histories WHERE WEEK = '#{last_week}' and year = '#{last_week_year}'
        ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
        LEFT JOIN
        (
          SELECT * FROM dbmarketing.tbidcabang
        ) cab ON cab.id = f1.branch
        GROUP BY cab.Cabang, f1.address_number, IFNULL(fw.brand, tl.jenisbrgdisc)
        ORDER BY IFNULL(fw.brand, tl.jenisbrgdisc), IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(SUM(tl.jumlah),0) DESC
        ) au WHERE au.brand IS NOT null
    ")
  end

  def self.batch_transform_retail(month, year)

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1BRAND (AREA, branch, cabang_id, brand,  fiscal_day, fiscal_month, fiscal_year, sales_quantity, sales_amount, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, DAY(tanggalsj), fiscal_month, fiscal_year, SUM(jumlah), SUM(harganetto2), NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc;")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1PRODUCT (AREA, branch, cabang_id, brand, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET1ARTICLE (AREA, branch, cabang_id, brand, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at, salesmen, salesmen_desc, city)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), nopo, salesman, kota
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET2PARENTCUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at, salesmen, salesmen_desc, city)
      SELECT area_id, jenisbrgdisc, groupcust, plankinggroup, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW(), nopo, salesman, kota
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, groupcust, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET2CUSPRODUCT (AREA, branch, cabang_id, brand, customer, customer_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET2CUSARTICLE (AREA, branch, cabang_id, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET3SALBRAND (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' AND harganetto2 > 0 GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET3SALPRODUCT (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET3SALARTICLE (AREA, branch, cabang_id, brand, salesmen, salesmen_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, nopo, salesman, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET4CITYBRAND (AREA, branch, cabang_id, brand, city, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET4CITYPRODUCT (AREA, branch, cabang_id, brand, city, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET4CITYARTICLE (AREA, branch, cabang_id, brand, city, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, area_id, cabang_id, jenisbrgdisc, kota, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, cabang_id, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("
      -- update data penjualan untuk forecast
	REPLACE INTO sales_mart.RET3SALITEMNUMBER (item_number, panjang, lebar, nopo, salesman, week, month, year, total)
	SELECT kodebrg, panjang, lebar, nopo, salesman, week, fiscal_month, fiscal_year, SUM(jumlah) as jumlah FROM tblaporancabang t 
	WHERE week = #{Date.today.cweek} and fiscal_year = #{Date.today.year} and nopo is not null and harganetto2 > 0
	GROUP BY kodebrg, nopo, salesman, week, fiscal_month, fiscal_year;")

    ActiveRecord::Base.connection.execute("-- update forecast per minggu, dijalankan setiap hari
	UPDATE forecasts f left join 
	(
	  SELECT item_number, SUM(total) AS total, nopo, week, year FROM sales_mart.RET3SALITEMNUMBER
	  WHERE week = #{Date.today.cweek} and year = #{Date.today.year} GROUP BY nopo, item_number, week, year
	) AS rs
	on f.address_number = rs.nopo and (f.item_number = rs.item_number and f.week = rs.week and f.year = rs.year)
	set f.sold = rs.total
	where f.`year` = #{Date.today.year} and f.week = #{Date.today.cweek} AND rs.total > 0;")
    ActiveRecord::Base.connection.execute("-- update outstanding forecast
	UPDATE forecasts set sisa = IF((quantity - sold) < 0, 0, (quantity - sold)) WHERE week = #{Date.today.cweek} 
	and `year` = #{Date.today.year};")
    ActiveRecord::Base.connection.execute("-- update rmse
	UPDATE forecasts set abs_error  = POWER((sold-quantity),2)  WHERE week = #{Date.today.cweek} and `year` = #{Date.today.year};")	
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

  def self.calculate_rkm(week1, week2)
    week = week1
    week_year = 2021
    last_week = week2
    last_week_year = 2021
    ActiveRecord::Base.connection.execute("
      INSERT INTO rkm_histories(branch, address_number, sales_name, WEEK, YEAR, item_number, size, brand, segment2_name,
        segment3_name, quantity)
        SELECT * FROM (
          SELECT f1.branch, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS WEEK,
              IFNULL(fw.year, tl.fiscal_year) AS YEAR, f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
              IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
              (IFNULL(fw.quantity, 0) - IFNULL(tl.jumlah,0) + IFNULL(rh.quantity,0)) FROM
              (
                SELECT item_number, address_number, branch FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{week_year}'
                AND address_number = '20081397' AND brand = 'ROYAL'
                GROUP BY address_number, item_number, branch

                UNION

                SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
                WHERE week = '#{week}' and fiscal_year = '#{week_year}' AND nopo = '20081397' AND jenisbrgdisc = 'ROYAL'
                AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX') GROUP BY area_id, kodebrg, nopo
              ) f1
              LEFT JOIN
              (
                SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{week_year}' GROUP BY branch, brand, address_number, item_number
              ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
              LEFT JOIN
              (
                SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK, fiscal_year
                FROM dbmarketing.tblaporancabang
                WHERE week = '#{week}' and fiscal_year = '#{week_year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
                AND ketppb NOT LIKE '%D'
                GROUP BY area_id, kodebrg, nopo
              ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
              LEFT JOIN
              (
                SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE WEEK = '#{last_week}' AND YEAR = '#{last_week_year}'
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

  def self.monthly_customer_active
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.CUSTOMER_GROWTHS(area_id, brand, total, new_customer, active_customer, inactive_customer, fmonth, fyear)
        SELECT area_id, jenisbrgdisc, COUNT(*) AS total_customer,
        COUNT(CASE WHEN min_dateorder BETWEEN '#{1.month.ago.beginning_of_month.to_date}' AND '#{1.month.ago.end_of_month.to_date}' THEN kode_customer END) AS new_customer,
        COUNT(CASE WHEN max_dateorder BETWEEN '#{3.month.ago.beginning_of_month.to_date}' AND '#{1.month.ago.end_of_month.to_date}' THEN kode_customer END) AS active_customer,
        COUNT(CASE WHEN max_dateorder BETWEEN '2018-01-01' AND '#{4.month.ago.end_of_month.to_date}' THEN kode_customer END) AS inactive_customer,
        8, 2019
        FROM
        (
          SELECT area_id, jenisbrgdisc, kode_customer, customer, COUNT(*), MIN(tanggalsj) AS min_dateorder, MAX(tanggalsj) AS max_dateorder
          FROM dbmarketing.tblaporancabang WHERE tanggalsj BETWEEN '2018-01-01' AND '#{1.month.ago.end_of_month.to_date}' AND tipecust = 'RETAIL'
          AND orty = 'RI' GROUP BY kode_customer, jenisbrgdisc, area_id
        ) AS sa
        WHERE jenisbrgdisc != '' GROUP BY jenisbrgdisc, area_id;
    ")

    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.CUSTOMER_DETGROWTHS(customer_id, customer, city, branch, brand, fmonth, fyear, last_invoice, created_at, salesman, cust_status)
        SELECT kode_customer, customer, kota, area_id, jenisbrgdisc,
        '#{1.month.ago.end_of_month.to_date.month}', '#{1.month.ago.end_of_month.to_date.year}', max_dateorder, NOW(), salesman,
        CASE
         WHEN min_dateorder BETWEEN '#{1.month.ago.beginning_of_month.to_date}' AND '#{1.month.ago.end_of_month.to_date}' THEN 'NEW'
         WHEN max_dateorder BETWEEN '#{3.month.ago.beginning_of_month.to_date}' AND '#{1.month.ago.end_of_month.to_date}' THEN 'ACTIVE'
         WHEN max_dateorder BETWEEN '2018-01-01' AND '#{4.month.ago.end_of_month.to_date}' THEN 'INACTIVE'
        END
        FROM
        (
          SELECT area_id, jenisbrgdisc, kode_customer, customer, kota, MAX(tanggalsj) AS max_dateorder, MIN(tanggalsj) AS min_dateorder, salesman
          FROM dbmarketing.tblaporancabang WHERE tanggalsj BETWEEN '2018-01-01' AND '#{1.month.ago.end_of_month.to_date}' AND tipecust = 'RETAIL'
          AND orty = 'RI' GROUP BY kode_customer, jenisbrgdisc, area_id
        ) AS sa
        WHERE max_dateorder BETWEEN '2018-01-01' AND '#{1.month.ago.end_of_month.to_date}' AND jenisbrgdisc != '' GROUP BY kode_customer, jenisbrgdisc;
    ")
  end
end
