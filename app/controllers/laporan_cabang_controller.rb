class LaporanCabangController < ApplicationController
  def index
    @laporancabang = LaporanCabang.get_record(params[:from], params[:to], current_user) unless params[:from].nil? && params[:to].nil?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporancabang }
    end
  end

  def comparison_by_year
    @cabang_get_id = Cabang.get_id
    #   find a week for report weekly
    unless params[:periode].nil? || params[:periode].nil?
     	@periode = params[:periode].to_date
			@this_week_on_current_year_first_day = Date.commercial(@periode.year, @periode.cweek, 1)
			@this_week_on_current_year_last_day = Date.commercial(@periode.year, @periode.cweek, 7)

			@this_week_on_last_year_first_day = Date.commercial(1.year.ago(@periode).year, @periode.cweek, 1)
			@this_week_on_last_year_last_day = Date.commercial(1.year.ago(@periode).year, @periode.cweek, 7)

			@last_week_on_current_year_first_day = Date.commercial(@periode.year, @periode.cweek - 1, 1)
			@last_week_on_current_year_last_day = Date.commercial(@periode.year, @periode.cweek - 1, 7)

			@last_week_on_last_year_first_day = Date.commercial(1.year.ago(@periode).year, @periode.cweek - 1, 1)
			@last_week_on_last_year_last_day = Date.commercial(1.year.ago(@periode).year, @periode.cweek - 1, 7)

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

  def group_by_cabang
    @cabang_get_id = Cabang.get_id
  end

	def group_by_category
    @cabang_get_id = Cabang.get_id
		@brand = Brand.all
  end

	def weekly_report
		@cabang_get_id = Cabang.get_id
		unless params[:periode_week].nil? || params[:periode_week].nil?
     	@periode = params[:periode_week].to_date
			@first_day_week_1 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek, 1)
			@last_day_week_1 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek, 7)

			@first_day_week_2 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 1, 1)
			@last_day_week_2 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 1, 7)

			@first_day_week_3 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 2, 1)
			@last_day_week_3 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 2, 7)

			@first_day_week_4 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 3, 1)
			@last_day_week_4 = Date.commercial(@periode.year, @periode.beginning_of_month.cweek + 3, 7)

			@first_day_week_5 = Date.commercial(@periode.year, @periode.end_of_month.cweek, 1)
			@last_day_week_5 = Date.commercial(@periode.year, @periode.end_of_month.cweek, 7)

			@last_year_last_day_week = Date.commercial(@periode.year - 1, @periode.end_of_month.cweek, 7)
    end
	end

end
