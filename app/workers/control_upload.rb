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

  def import_sales_jde
    JdeSoDetail.import_sales
    JdeSoDetail.import_outstanding_orders
    JdeSoDetail.import_outstanding_shipments
    JdeSoDetail.import_hold_orders
  end
  
  def import_credit_note
    JdeSoDetail.import_credit_note
  end
  
  def import_masters
    JdeCustomerMaster.customer_import
    JdeItemMaster.item_masters_fetch
    JdeItemMaster.get_new_items_from_jde
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
    JdeItemAvailability.import_stock_hourly_display
  end
  
  def import_stock_hourly
    JdeItemAvailability.import_stock_hourly
  end
  
  def import_beginning_of_week
    JdeItemAvailability.import_beginning_week_of_stock
  end

  def intransit_pos
    PosAutoIntransit.insert_delivered_stock_from_jde(Date.today)
  end
end
