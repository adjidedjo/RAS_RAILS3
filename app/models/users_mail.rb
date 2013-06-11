class UsersMail < ActiveRecord::Base
	belongs_to :user
	validates_uniqueness_of :user_id, :brand,:category, :cabang_id, :scope => [:user_id, :brand, :category, :cabang_id], 
		:message => "should happen once per brand and user"
end
