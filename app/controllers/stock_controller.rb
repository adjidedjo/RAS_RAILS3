class StockController < ApplicationController
  def index
    @id_cabang = Cabang.get_id
    @get_merk = Merk.all
    @get_stock = Stock.check_stock(params[:date]).group(:kodebrg) unless params[:date].nil?
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporancabang }
    end
  end

end
