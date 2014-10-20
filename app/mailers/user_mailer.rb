class UserMailer < ActionMailer::Base
  default from: "Admin Sales Analytic"

	def report
    email1 = "aji.y@ras.co.id"
    email2 = "ratna.d@ras.co.id"
    email3 = "irne@ras.co.id"
    email4 = "friedermorulak@ras.co.id"
    email5 = "rudy.s@ras.co.id"
    email6 = "daniel@ras.co.id"
    recipients = email1, email2, email3, email4, email5, email6
		@dates = Date.today.beginning_of_month..Date.today
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => email1, :subject => "Laporan Upload Data Penjualan Harian")
  end
  
  def account_approved(user)
    @user = User.where("email = ?", user)
    mail(:to => user, :subject => "Your Account Has Been Approved")
  end
  
  def sign_up(user)
    @user = User.where("email = ?", user)
    mail(:to => user, :subject => "Welcome to Sales Analytic")
  end
end
