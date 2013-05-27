class LaporanCabangController < ApplicationController

	def chart
		group_by_cabang
	end

	def group_category_type_comparison
		group_category_size_comparison
		@product = Product.all
	end

	def group_category_size_comparison
		group_category_type_comparison
	end

	def group_category_type_comparison
		group_categories_comparison
	end

	def group_category_customer_comparison
		group_categories_comparison
	end

	def group_categories_comparison
		monthly
		@brand = Brand.brand_id(params[:merk_id])
	end

	def monthly_customer_comparison
		monthly

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
	end

	def monthly_type_comparison
		monthly
		@product = Product.all

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
	end

	def monthly
		@cabang_get_id = Cabang.get_id
		@qty_last = 0
		@value_last = 0
		@qty_current = 0
		@value_current = 0
		unless params[:from].nil?
			@from_last_year = params[:from].to_date - 1.years
			@to_last_year = params[:to].to_date - 1.years
		end

		unless params[:user_brand].nil?
			if params[:user_brand].slice(0) == "A"
				@brand = Brand.all
			else
				@brand = Brand.where(["KodeBrand like ?", %(#{params[:user_brand].slice(0)}%)])
			end
		end
	end

	def monthly_category_comparison
		monthly

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
	end

	def monthly_comparison
		monthly

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
	end

  def index
    @laporancabang = LaporanCabang.conditional_detail(params[:merk_id], params[:from], params[:to], current_user,
			params[:customer], params[:customer2]) unless params[:from].nil? && params[:to].nil?
  end

  def comparison_by_year
    @cabang_get_id = Cabang.get_id
    #   find a week for report weekly
    unless params[:periode].nil? || params[:periode].nil?
     	@periode = params[:periode].to_date
			calculation_date_compare_year(@periode, params[:periode])
    end
  end

  def control_branches_sales
    @dates = params[:from].to_date..params[:to].to_date unless params[:from].nil? && params[:to].nil?
    @cabang_get_id = Cabang.get_id
  end

  def group_by_merk_type
		group_by_type
		@kodebrg = LaporanCabang.query_by_date(params[:from], params[:to])
  end

  def group_by_merk_size
		@cabang_get_id = Cabang.get_id
  end

  def group_by_merk_customer
		@cabang_get_id = Cabang.get_id
  end

  def group_by_merk
		@category_merk = Brand.brand_id(params[:merk_id])
    @cabang_get_id_to_7 = Cabang.get_id_to_7
		@cabang_get_id_to_22 = Cabang.get_id_to_22
  end

  def group_by_type
    @cabang_get_id_to_7 = Cabang.get_id_to_7
		@cabang_get_id_to_22 = Cabang.get_id_to_22
		@product = Product.all
  end

  def group_by_customer
		@cabang_get_id = Cabang.get_id
  end

  def group_by_cabang
    @cabang_get_id_to_7 = Cabang.get_id_to_7
		@cabang_get_id_to_22 = Cabang.get_id_to_22

		respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.xml
    end
  end

	def group_by_category
    @cabang_get_id_to_7 = Cabang.get_id_to_7
		@cabang_get_id_to_22 = Cabang.get_id_to_22

		if params[:user_brand].slice(0) == "A"
			@brand = Brand.all
		else
			@brand = Brand.where(["KodeBrand like ?", %(#{params[:user_brand].slice(0)}%)])
		end

		respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

	def weekly_report
		@cabang_get_id = Cabang.get_id
		@week1 = 0
		@week2 = 0
		@week3 = 0
		@week4 = 0
		@week5 = 0
		unless params[:periode_week].nil? || params[:periode_week].nil?
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

			@first_day_week_5 = Date.commercial(date.year, date.end_of_month.cweek, 1)
			@last_day_week_5 = Date.commercial(date.year, date.end_of_month.cweek, 7)

			@first_day_last_month_week = Date.commercial(date.year, date.cweek - 4, 1)
			@last_day_last_month_week = Date.commercial(date.year, date.cweek - 4, 7)

			@last_year_last_day_week = Date.commercial(date.year - 1, date.end_of_month.cweek, 7)
	end

	def calculation_date_compare_year(periode, date)
			@this_week_on_current_year_first_day = Date.commercial(periode.year, periode.cweek, 1)
			@this_week_on_current_year_last_day = Date.commercial(periode.year, periode.cweek, 7)

			@this_week_on_last_year_first_day = Date.commercial(1.year.ago(periode).year, periode.cweek, 1)
			@this_week_on_last_year_last_day = Date.commercial(1.year.ago(periode).year, periode.cweek, 7)

			@last_week_on_current_year_first_day = Date.commercial(periode.year, periode.cweek - 1, 1)
			@last_week_on_current_year_last_day = Date.commercial(periode.year, periode.cweek - 1, 7)

			@last_week_on_last_year_first_day = Date.commercial(1.year.ago(periode).year, periode.cweek - 1, 1)
			@last_week_on_last_year_last_day = Date.commercial(1.year.ago(periode).year, periode.cweek - 1, 7)

      @this_week_on_current_year = (date.to_date - 6.days).to_date
      @this_week_on_last_year = 1.year.ago(date.to_date - 6.days).to_date
      @last_week_on_current_year = 1.weeks.ago(date.to_date - 6.days).to_date
      @last_week_on_last_year = 1.year.ago(1.weeks.ago(date.to_date - 6.days)).to_date
	end
end
