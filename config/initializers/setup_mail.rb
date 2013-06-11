ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "royalabadisejahtera.com",
  :user_name            => "springbedelite",
  :password             => "springB3D",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
