class CostOfGoodsController < ApplicationController
  # GET /cost_of_goods
  # GET /cost_of_goods.json
  def index
    @cost_of_goods = CostOfGood.all

    respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json { render json: @cost_of_goods }
    end
  end

  # GET /cost_of_goods/1
  # GET /cost_of_goods/1.json
  def show
    @cost_of_good = CostOfGood.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cost_of_good }
    end
  end

  # GET /cost_of_goods/new
  # GET /cost_of_goods/new.json
  def new
    @cost_of_good = CostOfGood.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cost_of_good }
    end
  end

  # GET /cost_of_goods/1/edit
  def edit
    @cost_of_good = CostOfGood.find(params[:id])
  end

  # POST /cost_of_goods
  # POST /cost_of_goods.json
  def create
    @cost_of_good = CostOfGood.new(params[:cost_of_good])

    respond_to do |format|
      if @cost_of_good.save
        format.html { redirect_to @cost_of_good, notice: 'Margin diskon was successfully created.' }
        format.json { render json: @cost_of_good, status: :created, location: @cost_of_good }
      else
        format.html { render action: "new" }
        format.json { render json: @cost_of_good.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cost_of_goods/1
  # PUT /cost_of_goods/1.json
  def update
    @cost_of_good = CostOfGood.find(params[:id])

    respond_to do |format|
      if @cost_of_good.update_attributes(params[:cost_of_good])
        format.html { redirect_to @cost_of_good, notice: 'Cost of good was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @cost_of_good.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cost_of_goods/1
  # DELETE /cost_of_goods/1.json
  def destroy
    @cost_of_good = CostOfGood.find(params[:id])
    @cost_of_good.destroy

    respond_to do |format|
      format.html { redirect_to cost_of_goods_url }
      format.json { head :ok }
    end
  end
end
