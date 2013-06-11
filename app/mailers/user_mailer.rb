class UserMailer < ActionMailer::Base
  default from: "springbedelite@gmail.com"

	def report(user)
		@product = Product.all
		@user = user
    @cabang_get_id_to_7 = Cabang.get_id_to_7
		@cabang_get_id_to_22 = Cabang.get_id_to_22
		#attachments["HBS_Classic.ods"] = File.read("#{Rails.root}/public/HBS_Classic.ods")
    mail(:to => "#{user.username} <#{user.email}>", :subject => "Report")
  end
end
