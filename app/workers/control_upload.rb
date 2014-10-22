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
  
  def update_price_list
    Regional.update_harga
    Regional.update_discount
    Regional.update_upgrade
    Regional.update_cashback
    Regional.update_special_price
  end
  
  def check_reports
    PriceList.check_report_price_list(Date.today.month, Date.today.year)
  end
end