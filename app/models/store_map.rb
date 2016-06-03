class StoreMap < ActiveRecord::Base
#	acts_as_gmappable

	def gmaps4rails_address
  	"#{address}, #{city}"
	end
end
