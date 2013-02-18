class LaporanCabangController < ApplicationController
  def index
    @laporancabang = LaporanCabang.query_by_date(params[:from], params[:to])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporancabang }
    end
  end
  
  def comparison_by_year
    
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def control_branches_sales
    @dates = params[:from].to_date..params[:to].to_date unless params[:from].nil? && params[:to].nil?
    @model = params[:category] == "Penjualan" ? LaporanCabang : Stock
    @get_value = @model.query_by_date(params[:from],params[:to])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @control_branches }
    end
  end
end
