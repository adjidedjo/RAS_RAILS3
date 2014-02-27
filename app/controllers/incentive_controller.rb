class IncentiveController < ApplicationController
  def index
    @sales = Salesman.all
  end

end
