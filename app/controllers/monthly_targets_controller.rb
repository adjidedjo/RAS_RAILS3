class MonthlyTargetsController < ApplicationController
  # GET /monthly_targets
  # GET /monthly_targets.json
  def index
    @monthly_targets = MonthlyTarget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @monthly_targets }
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
