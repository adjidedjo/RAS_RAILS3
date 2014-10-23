class FuturePriceListsController < ApplicationController
  # GET /future_price_lists
  # GET /future_price_lists.json
  def index
    @future_price_lists = FuturePriceList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @future_price_lists }
    end
  end

  # GET /future_price_lists/1
  # GET /future_price_lists/1.json
  def show
    @future_price_list = FuturePriceList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @future_price_list }
    end
  end

  # GET /future_price_lists/new
  # GET /future_price_lists/new.json
  def new
    @future_price_list = FuturePriceList.new
    @jenis = Product.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @future_price_list }
    end
  end

  # GET /future_price_lists/1/edit
  def edit
    @future_price_list = FuturePriceList.find(params[:id])
  end

  # POST /future_price_lists
  # POST /future_price_lists.json
  def create
    @future_price_list = FuturePriceList.new(params[:future_price_list])

    respond_to do |format|
      if @future_price_list.save
        format.html { redirect_to @future_price_list, notice: 'Future price list was successfully created.' }
        format.json { render json: @future_price_list, status: :created, location: @future_price_list }
      else
        format.html { render action: "new" }
        format.json { render json: @future_price_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /future_price_lists/1
  # PUT /future_price_lists/1.json
  def update
    @future_price_list = FuturePriceList.find(params[:id])

    respond_to do |format|
      if @future_price_list.update_attributes(params[:future_price_list])
        format.html { redirect_to @future_price_list, notice: 'Future price list was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @future_price_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /future_price_lists/1
  # DELETE /future_price_lists/1.json
  def destroy
    @future_price_list = FuturePriceList.find(params[:id])
    @future_price_list.destroy

    respond_to do |format|
      format.html { redirect_to future_price_lists_url }
      format.json { head :ok }
    end
  end
end
