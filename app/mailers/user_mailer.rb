class UserMailer < ActionMailer::Base
  default from: "Royal Corporation <support@ras.co.id>"
  
  def order(email, user, name, add1, add2, city, req_date, detail, order_number, cus_city, cus_add)
    @user = user.upcase
    @mlname = name.blank? ? '-' : name.strip 
    @add1 = add1
    @add2 = add2
    @city = city
    @date = req_date
    @detail = detail
    @order_no = order_number
    @req_date = req_date
    @cuscity = cus_city
    @cusadd = cus_add
    mail(:to => email, :subject => "Konfirmasi Order", :bcc => ["aji.y@ras.co.id", "daniel@ras.co.id"])
  end
  
  def kontra_bon
    recipients = ["wiliam.w@ras.co.id", "endang.l@ras.co.id", "irne@ras.co.id", "daniel@ras.co.id", 
      "rudy.s@ras.co.id"]
    mail(:to => recipients, :cc => ["aji.y@ras.co.id", "fenny@ras.co.id"], 
    :subject => "Laporan Hasil Kontra Bon JDE")
  end

  def report_stock
    recipient_to = []
    recipient_cc = []
    Recipient.where("mailing_for in (?)", ["stock", "all"]).each do |rec|
      recipient_to << rec.email if rec.cc == false
      recipient_cc << rec.email if rec.cc == true
    end
	  @dates = Date.today.beginning_of_month..Date.today
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    @cabang_get_id = Cabang.get_id
    mail(:to => recipient_to, :cc => recipient_cc, :subject => "Laporan Upload Data Stock Harian")
  end

  def report
    recipient_to = []
    recipient_cc = []
    Recipient.where("mailing_for in (?)", ["penjualan", "all"]).each do |rec|
      recipient_to << rec.email if rec.cc == false
      recipient_cc << rec.email if rec.cc == true
    end
    @dates = Date.today.beginning_of_month..Date.today
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => "aji.y@ras.co.id",:subject => "Laporan Upload Data Penjualan Harian")
  end

  def report_previous_month
    recipient_to = []
    recipient_cc = []
    Recipient.where("mailing_for in (?)", ["penjualan", "all"]).each do |rec|
      recipient_to << rec.email if rec.cc == false
      recipient_cc << rec.email if rec.cc == true
    end
    @dates = 1.month.ago.beginning_of_month.to_date..1.month.ago.end_of_month.to_date
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => recipient_to, :cc => recipient_cc, :subject => "Laporan Upload Data Penjualan Harian Bulan Lalu")
  end

  def account_approved(user)
    @user = User.where("email = ?", user)
    mail(:to => user, :subject => "Your Account Has Been Approved")
  end

  def sign_up(admin, user)
    @user = user
    mail(:to => admin.email, :subject => "New User has been sign up")
  end
end
