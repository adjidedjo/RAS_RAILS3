class UserMailer < ActionMailer::Base
  default from: "admin_sales_analytic@ras.co.id"

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
    mail(:to => recipient_to, :cc => recipient_cc,:subject => "Laporan Upload Data Penjualan Harian")
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
