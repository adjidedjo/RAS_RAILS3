class LaporanCabangController < ApplicationController
  def index
    @laporancabang = LaporanCabang.order("id desc").query_by_date(params[:from], params[:to])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporancabang }
    end
  end
  
  def comparison_by_year
    @cabang_get_id = Cabang.get_id
    #   find a week for report weekly
    unless params[:periode].nil? || params[:periode].nil?
      @periode = params[:periode]
      @this_week_on_current_year = (params[:periode].to_date - 6.days).to_date
      @this_week_on_last_year = 1.year.ago(params[:periode].to_date - 6.days).to_date
      @last_week_on_current_year = 1.weeks.ago(params[:periode].to_date - 6.days).to_date
      @last_week_on_last_year = 1.year.ago(1.weeks.ago(params[:periode].to_date - 6.days)).to_date
    end
      
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def control_branches_sales
    @dates = params[:from].to_date..params[:to].to_date unless params[:from].nil? && params[:to].nil?
    @cabang_get_id = Cabang.get_id
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @control_branches }
    end
  end
end
