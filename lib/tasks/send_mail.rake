namespace :mailer do
   task :upload_control => :environment do
      UserMailer.report.deliver
   end
end