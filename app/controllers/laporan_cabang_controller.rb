class LaporanCabangController < ApplicationController

	def update_kain
    # updates artists and songs based on genre selected
    # map to name and id for use in our options_for_select
		@fabric = Kain.get_kain_name(params[:artikel_id]).map{|a| [a.NamaKain, a.KodeKain]}.insert(0, "Select Fabric")
	end

	def update_article
    # updates artists and songs based on genre selected
    # map to name and id for use in our options_for_select
		@article = Artikel.get_name(params[:type_id]).map{|a| [a.Produk, a.KodeCollection]}.insert(0, "Select Article")
	end

  def control_branches_sales
    @dates = params[:from].to_date..params[:to].to_date unless params[:from].nil? && params[:to].nil?
    @cabang_get_id = Cabang.get_id
    @cabang_get_id_first = Cabang.get_id_to_7
    @cabang_get_id_second = Cabang.get_id_to_22
  end

	def weekly_report
		@cabang_get_id = Cabang.branch_get_name(current_user)
		@week1 = 0
		@week2 = 0
		@week3 = 0
		@week4 = 0
		@week5 = 0
		unless params[:periode_week].nil?
      @periode = params[:periode_week].to_date
		  calculation_date_weekly_report(@periode)
    end

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
	end

	def calculation_date_weekly_report(date)
    @first_day_week_1 = Date.commercial(date.year, date.beginning_of_month.cweek, 1)
    @last_day_week_1 = Date.commercial(date.year, date.beginning_of_month.cweek, 7)

    @first_day_week_2 = Date.commercial(date.year, date.beginning_of_month.cweek + 1, 1)
    @last_day_week_2 = Date.commercial(date.year, date.beginning_of_month.cweek + 1, 7)

    @first_day_week_3 = Date.commercial(date.year, date.beginning_of_month.cweek + 2, 1)
    @last_day_week_3 = Date.commercial(date.year, date.beginning_of_month.cweek + 2, 7)

    @first_day_week_4 = Date.commercial(date.year, date.beginning_of_month.cweek + 3, 1)
    @last_day_week_4 = Date.commercial(date.year, date.beginning_of_month.cweek + 3, 7)

    @first_day_week_5 = Date.commercial(date.year, date.beginning_of_month.cweek + 4, 1)
    @last_day_week_5 = Date.commercial(date.year, date.beginning_of_month.cweek + 4, 7)

    @first_day_last_month_week = Date.commercial(date.year, date.beginning_of_month.cweek - 5, 1)
    @last_day_last_month_week = Date.commercial(date.year, date.beginning_of_month.cweek - 5, 7)

    @last_year_last_day_week = Date.commercial(date.year - 1, date.end_of_month.cweek, 7)
	end
end
