class PagesController < ApplicationController
	skip_before_filter :authenticate_user!

  def home
		respond_to do |format|
      format.html
    end
  end
end
