class SalesProductivitiesController < ApplicationController
  def report_graph
    brand = params[:brand].present? ? Merk.find_by_jde_brand(params[:brand]).id : 0
    cabang = params[:branch].present? ? params[:branch] : 0
    month = params[:month].present? ? params[:month] : Date.today.month
    year = params[:date].present? ? params[:date][:year] : Date.today.year
    @sales = SalesProductivityReport.find_by_sql("SELECT * 
    FROM sales_productivity_reports WHERE month = #{month} AND year = #{year} AND brand_id = #{brand} 
    AND branch_id = #{cabang}")

    @sales = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Sales Productivity")
      f.options[:xAxis] = {
    :title => { :text => nil },
    :labels => { :enabled => false }
 }
      f.xAxis(:categories => @sales.map { |i| [Salesman.find(i.salesmen_id).nama] })
      f.yAxis [
          {:title => {:text => "Visit Percentage", :margin => 70} },
          {:title => {:text => "Success Rate Percentage"}},
          {:title => {:text => "Order Deal Percentage"}, :opposite => true},
          {:title => {:text => "Call a Day Percentage"}, :opposite => true},
        ]
      f.series(:name => 'Average Visit per Day', :yAxis => 0,
               :data => @sales.map { |i| [Salesman.find(i.salesmen_id).nama,
                                      i.average_visit_day] })
      f.series(:name => 'Average Success Rate Visit', :yAxis => 1, :type => 'spline',
               :data => @sales.map { |i| [Salesman.find(i.salesmen_id).nama,
                                      i.success_rate_visit] })

      f.series(:name => 'Average Order Deal', :yAxis => 2, :type => 'spline',
               :data => @sales.map { |i| [Salesman.find(i.salesmen_id).nama,
                                      i.average_order_deal] })

      f.series(:name => 'Average Call a Day', :yAxis => 3, :type => 'spline',
               :data => @sales.map { |i| [Salesman.find(i.salesmen_id).nama,
                                      i.average_call_day] })

      f.legend(:align => 'left', :verticalAlign => 'top', :y => 55, :x => 80, :layout => 'vertical',
      :floating => true)
      f.chart({:defaultSeriesType => 'column'})
    end
  end

  # GET /sales_productivities
  # GET /sales_productivities.json
  def index
    @sales_productivities = SalesProductivity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sales_productivities }
    end
  end

  # GET /sales_productivities/1
  # GET /sales_productivities/1.json
  def show
    @sales_productivity = SalesProductivity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sales_productivity }
    end
  end

  # GET /sales_productivities/new
  # GET /sales_productivities/new.json
  def new
    @sales_productivity = SalesProductivity.new
    @salesman = Salesman.where(branch_id: current_user.province)
    @brand = Merk.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sales_productivity }
    end
  end

  # GET /sales_productivities/1/edit
  def edit
    @sales_productivity = SalesProductivity.find(params[:id])
  end

  # POST /sales_productivities
  # POST /sales_productivities.json
  def create
    @sales_productivity = SalesProductivity.new(params[:sales_productivity])

    respond_to do |format|
      if @sales_productivity.save
        format.html { redirect_to new_sales_productivity_path, notice: 'Sales productivity was successfully created.' }
        format.json { render json: @sales_productivity, status: :created, location: @sales_productivity }
      else
        @salesman = Salesman.where(id: params[:sales_productivity]["salesmen_id"])
        @brand = Merk.all
        format.html { render action: "new" }
        format.json { render json: @sales_productivity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sales_productivities/1
  # PUT /sales_productivities/1.json
  def update
    @sales_productivity = SalesProductivity.find(params[:id])

    respond_to do |format|
      if @sales_productivity.update_attributes(params[:sales_productivity])
        format.html { redirect_to @sales_productivity, notice: 'Sales productivity was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @sales_productivity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_productivities/1
  # DELETE /sales_productivities/1.json
  def destroy
    @sales_productivity = SalesProductivity.find(params[:id])
    @sales_productivity.destroy

    respond_to do |format|
      format.html { redirect_to sales_productivities_url }
      format.json { head :ok }
    end
  end
end
