class MonthlyRetailsController < ApplicationController
  # GET /monthly_retails
  # GET /monthly_retails.json
  def index
    @monthly_retails = MonthlyRetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @monthly_retails }
    end
  end

  # GET /monthly_retails/1
  # GET /monthly_retails/1.json
  def show
    @monthly_retail = MonthlyRetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @monthly_retail }
    end
  end

  # GET /monthly_retails/new
  # GET /monthly_retails/new.json
  def new
    @monthly_retail = MonthlyRetail.new
		@merk = Merk.all.collect {|a| [a.Merk, a.id]}
		@cabang = Cabang.get_id.collect {|a| [a.Cabang, a.id]}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @monthly_retail }
    end
  end

  # GET /monthly_retails/1/edit
  def edit
    @monthly_retail = MonthlyRetail.find(params[:id])
		@merk = Merk.all.collect {|a| [a.Merk, a.id]}
		@cabang = Cabang.get_id.collect {|a| [a.Cabang, a.id]}
  end

  # POST /monthly_retails
  # POST /monthly_retails.json
  def create
    @monthly_retail = MonthlyRetail.new(params[:monthly_retail])

    respond_to do |format|
      if @monthly_retail.save
        format.html { redirect_to monthly_retails_path, notice: 'Monthly retail was successfully created.' }
        format.json { render json: @monthly_retail, status: :created, location: @monthly_retail }
      else
        format.html { render action: "new" }
        format.json { render json: @monthly_retail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /monthly_retails/1
  # PUT /monthly_retails/1.json
  def update
    @monthly_retail = MonthlyRetail.find(params[:id])

    respond_to do |format|
      if @monthly_retail.update_attributes(params[:monthly_retail])
        format.html { redirect_to monthly_retails_path, notice: 'Monthly retail was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @monthly_retail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monthly_retails/1
  # DELETE /monthly_retails/1.json
  def destroy
    @monthly_retail = MonthlyRetail.find(params[:id])
    @monthly_retail.destroy

    respond_to do |format|
      format.html { redirect_to monthly_retails_url }
      format.json { head :ok }
    end
  end
end
