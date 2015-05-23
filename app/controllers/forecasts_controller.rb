class ForecastsController < ApplicationController
  # GET /forecasts
  # GET /forecasts.json
  def index
    if params[:branch_forecast].present?
      @forecasts = Forecast.cabang(params[:branch_forecast]).bulan(params[:month_forecast]).tahun(params["date"]["year"])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @forecasts }
    end
  end

  # GET /forecasts/1
  # GET /forecasts/1.json
  def show
    @forecast = Forecast.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @forecast }
    end
  end

  # GET /forecasts/new
  # GET /forecasts/new.json
  def new
    @forecast = Forecast.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @forecast }
    end
  end

  # GET /forecasts/1/edit
  def edit
    @forecast = Forecast.find(params[:id])
  end

  # POST /forecasts
  # POST /forecasts.json
  def create
    @forecast = Forecast.new(params[:forecast])

    respond_to do |format|
      if @forecast.save
        format.html { redirect_to @forecast, notice: 'Forecast was successfully created.' }
        format.json { render json: @forecast, status: :created, location: @forecast }
      else
        format.html { render action: "new" }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /forecasts/1
  # PUT /forecasts/1.json
  def update
    @forecast = Forecast.find(params[:id])

    respond_to do |format|
      if @forecast.update_attributes(params[:forecast])
        format.html { redirect_to @forecast, notice: 'Forecast was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forecasts/1
  # DELETE /forecasts/1.json
  def destroy
    @forecast = Forecast.find(params[:id])
    @forecast.destroy

    respond_to do |format|
      format.html { redirect_to forecasts_url }
      format.json { head :ok }
    end
  end
end
