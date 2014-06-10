class MonthlyTargetsController < ApplicationController

  def target_filter
    @date = Date.today
    @months = []
    0.downto(-3).each do |m|
      @months << [@date.months_since(m).strftime("%b %Y"), @date.next_month(m)]
    end
    if params[:targets] == 'branch'
      redirect_to monthly_targets_view_target_path(request.query_parameters) unless params[:month_year].nil?
    else
      redirect_to monthly_targets_view_target_sales_path(request.query_parameters) unless params[:month_year].nil?
    end
  end
  
  def view_target_sales
    @targets_sales = MonthlyTarget.get_target_by_sales(params[:cabang_id], params[:merk_id], params[:month_year])
  end

  def view_target
    @targets = MonthlyTarget.get_target_by_branch(params[:cabang_id], params[:merk_id], params[:month_year])
  end

  # GET /monthly_targets
  # GET /monthly_targets.json
  def index
    @monthly_targets = MonthlyTarget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @monthly_targets } == nil
    end
  end

  # GET /monthly_targets/1
  # GET /monthly_targets/1.json
  def show
    @monthly_target = MonthlyTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @monthly_target }
    end
  end

  # GET /monthly_targets/new
  # GET /monthly_targets/new.json
  def new
    @monthly_target = MonthlyTarget.new
    @date = Date.today
    @months = []
    (0..11).each do |m|
      @months << [@date.next_month(m).strftime("%Y"), @date.next_month(m)]
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @monthly_target }
    end
  end

  # GET /monthly_targets/1/edit
  def edit
    @monthly_target = MonthlyTarget.find(params[:id])
  end

  # POST /monthly_targets
  # POST /monthly_targets.json
  def create
    @monthly_target = MonthlyTarget.new(params[:monthly_target])
    @monthly_target.target_year = params[:date][:target_year]

    respond_to do |format|
      if @monthly_target.save
        format.html { redirect_to monthly_targets_path, notice: 'Monthly target was successfully created.' }
        format.json { render json: @monthly_target, status: :created, location: @monthly_target }
      else
        format.html { render action: "new" }
        format.json { render json: @monthly_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /monthly_targets/1
  # PUT /monthly_targets/1.json
  def update
    @monthly_target = MonthlyTarget.find(params[:id])

    respond_to do |format|
      if @monthly_target.update_attributes(params[:monthly_target])
        format.html { redirect_to monthly_targets_path, notice: 'Monthly target was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @monthly_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monthly_targets/1
  # DELETE /monthly_targets/1.json
  def destroy
    @monthly_target = MonthlyTarget.find(params[:id])
    @monthly_target.destroy

    respond_to do |format|
      format.html { redirect_to monthly_targets_url, notice: 'Monthly target was successfully removed.'  }
      format.json { head :ok }
    end
  end
end
