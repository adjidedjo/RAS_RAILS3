class PeddlersController < ApplicationController

  def peddlers_report
    @branch = Cabang.all
    first_week = Date.today.beginning_of_week
    last_week = Date.today.end_of_week
    @get_stock = Stock.check_stock_asongan(first_week, last_week, params[:branch]) if params[:branch]

    respond_to do |format|
      format.html
      format.xls
    end
  end

end
