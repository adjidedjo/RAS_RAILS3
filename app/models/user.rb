class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  belongs_to :merk
	has_many :users_mail
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :login, 
		:approved, :user_brand, :branch, :sales_stock
  attr_accessor :login
  after_create :send_welcome_mail
  
  def send_welcome_mail
    UserMailer.sign_up(self.email).deliver
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

	def active_for_authentication? 
  	super && approved? 
	end 

	def inactive_message 
		if !approved? 
		  :not_approved 
		else 
		  super # Use whatever other message 
		end 
	end

	def self.send_mail
		User.all.each do |user|
			UserMailer.report(user).deliver
		end
	end
end
