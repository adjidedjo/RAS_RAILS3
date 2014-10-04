class UserMailer < ActionMailer::Base
  default from: "elitespringbedmattress@gmail.com"

	def report(user)
    email1 = "aji.y@ras.co.id"
    email2 = "adji.el.djo@gmail.com"
    email3 = "ratna.d@ras.co.id"
    recipients = email1, email2, email3
		@dates = Date.today.beginning_of_month..Date.today
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
    mail(:to => recipients.join(','), :subject => "Laporan Upload Data Penjualan Harian")
  end
end
