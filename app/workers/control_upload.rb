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
  
  def import_customers
    JdeCustomerMaster.customer_import
  end
  
  def import_base_prices
    JdeBasePrice.import_base_price
  end
  
  def sunday_weekly_batch
    JdeFetch.checking_buffer
    JdeFetch.checking_item_cost
  end
  
  def import_acc_receivable
    JdeSoDetail.import_acc_receivable
  end
  
  def import_stock_hourly_display
    JdeSoDetail.import_stock_hourly_display
  end
  
  def import_stock_hourly
    JdeSoDetail.import_stock_hourly
  end
  
  def import_beginning_of_week
    JdeSoDetail.import_beginning_week_of_stock
  end
  
  def import_credit_note
    JdeSoDetail.import_credit_note
  end

  def import_sales_jde
    JdeSoDetail.import_sales
    JdeSoDetail.import_retur
  end

  def intransit_pos
    PosAutoIntransit.insert_delivered_stock_from_jde(Date.today)
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
    SqlFreeStock.migration_stok
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
    PriceList.check_availability_master
    PriceList.check_report_price_list
    LaporanCabang.sales_by_brand(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_product(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_article(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_fabric(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_customer(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_customer_by_brand(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_salesmen(Date.today.month, Date.today.year)
    LaporanCabang.sales_by_size(Date.today.day, Date.today.month, Date.today.year)
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
    (1..31).each do |day|
      LaporanCabang.sales_by_size(day, Date.today.prev_month.month, Date.today.prev_month.year)
    end
  end

  def update_customer
    LaporanCabang.update_customer(Date.today.month, Date.today.year)
  end

  def daily_migration
    SqlSales.migration_sales_report
    LaporanCabang.sales_by_brand(Date.today.month, Date.today.year)
  end

  def daily_new_item
    JdeItemMaster.get_new_items_from_jde
  end

  def monthly_net_sales
    SalesBrand.net_sales_update_cabang
    SalesBrand.net_sales_update_customer
  end

  def send_email_kontra_bon
    UserMailer.kontra_bon.deliver
  end
end
