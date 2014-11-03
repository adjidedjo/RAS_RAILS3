class UserMailer < ActionMailer::Base
  default from: "Admin Sales Analytic"

	def report
    email1 = "aji.y@ras.co.id"
    email2 = "ratna.d@ras.co.id"
    email3 = "irne@ras.co.id"
    email4 = "daniel@ras.co.id"
    email5 = "rudy.s@ras.co.id"
    recipients = email1, email2, email3, email4, email5
		@dates = Date.today.beginning_of_month..Date.today
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => recipients, :subject => "Laporan Upload Data Penjualan Harian")
  end
  
  def report_previous_month
    email1 = "aji.y@ras.co.id"
    email2 = "ratna.d@ras.co.id"
    email3 = "irne@ras.co.id"
    email4 = "daniel@ras.co.id"
    email5 = "rudy.s@ras.co.id"
    recipients = email1, email2, email3, email4, email5
		@dates = 1.month.ago.beginning_of_month.to_date..1.month.ago.end_of_month.to_date
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => recipients, :subject => "Laporan Upload Data Penjualan Harian Bulan Lalu")
  end
  
  def account_approved(user)
    @user = User.where("email = ?", user)
    mail(:to => user, :subject => "Your Account Has Been Approved")
  end
  
  def sign_up(user)
    @user = User.find_by_email(user)
    mail(:to => user, :subject => "Welcome to Sales Analytic")
  end
end
