class ControlUpload

  class << self

    def perform(method)
      with_logging method do
        self.new.send(method)
      end
    end

    def with_logging(method, &block)
      log("starting...", method)

      time = Benchmark.ms do
        yield block
      end

      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "#{now} %s#%s - #{message}" % [self.name, method]
    end

  end

  def send_mail
    UserMailer.report.deliver
  end

  def send_mail_previous_month
    UserMailer.report_previous_month.deliver
  end

  def send_mail_report_stock
    UserMailer.report_stock.deliver
  end

  def check_stock
    SqlFreeStock.migration_stok(Date.today.month, Date.today.year)
  end

  def update_price_list
    Regional.update_harga
    Regional.update_discount
    Regional.update_upgrade
    Regional.update_cashback
    Regional.update_special_price
  end

  def check_reports
    LaporanCabang.create_new_artikel_from_report(Date.today.month, Date.today.year)
    PriceList.check_availability_master(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_brand(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_product(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_article(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_fabric(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_customer(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_customer_by_brand(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_salesmen(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_size(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_customer_by_brand_yearly(Date.today.year)
  end

  def check_reports_prev_month
    LaporanCabang.sales_by_brand(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_product(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_article(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_fabric(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_customer(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_customer_by_brand(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_salesmen(Date.today.prev_month.month, Date.today.prev_month.year)
    LaporanCabang.sales_by_size(Date.today.prev_month.month, Date.today.prev_month.year)
  end

  def update_customer
    LaporanCabang.update_customer(Date.today.month, Date.today.year)
  end

  def daily_migration_prev_month
    SqlSales.migration_sales_report_prev_month
  end

  def daily_migration
    SqlSales.migration_sales_report
    PriceList.check_report_price_list
  end
end
