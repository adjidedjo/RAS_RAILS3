class YearlyTargetsController < ApplicationController
  # GET /yearly_targets
  # GET /yearly_targets.json
  def index
    @yearly_targets = YearlyTarget.all

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /yearly_targets/1
  # GET /yearly_targets/1.json
  def show
    @yearly_target = YearlyTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @yearly_target }
    end
  end

  # GET /yearly_targets/new
  # GET /yearly_targets/new.json
  def new
    @yearly_target = YearlyTarget.new

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /yearly_targets/1/edit
  def edit
    @yearly_target = YearlyTarget.find(params[:id])
  end

  # POST /yearly_targets
  # POST /yearly_targets.json
  def create
    @yearly_target = YearlyTarget.new(params[:yearly_target])

    respond_to do |format|
      if @yearly_target.save
        format.html { redirect_to yearly_targets_path, notice: 'Yearly target was successfully created.' }
        format.json { render json: @yearly_target, status: :created, location: @yearly_target }
      else
        format.html { render action: "new" }
        format.json { render json: @yearly_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /yearly_targets/1
  # PUT /yearly_targets/1.json
  def update
    @yearly_target = YearlyTarget.find(params[:id])

    respond_to do |format|
      if @yearly_target.update_attributes(params[:yearly_target])
        format.html { redirect_to yearly_targets_path, notice: 'Yearly target was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @yearly_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /yearly_targets/1
  # DELETE /yearly_targets/1.json
  def destroy
    @yearly_target = YearlyTarget.find(params[:id])
    @yearly_target.destroy

    respond_to do |format|
      format.html { redirect_to yearly_targets_url, notice: 'Yearly target was successfully removed.' }
      format.json { head :ok }
    end
  end
end
