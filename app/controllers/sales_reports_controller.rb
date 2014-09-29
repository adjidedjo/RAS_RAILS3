class SalesReportsController < ApplicationController
  include SalesReportsHelper
  
  def pilihan_brand
    redirect_to sales_reports_path(:brand => params[:brand], :branch => params[:branch], :date => params[:date]['month'].to_i) if params[:brand].present?
  end
  
  # GET /sales_reports
  # GET /sales_reports.json
  def index
    unless params[:branch].blank? && params[:brand].blank?
      faktur = SalesReport.select('nofaktur').search_by_month_and_year(params[:date]['month'].to_i, Date.today.year)
      .brand(brand(params[:brand])).search_by_branch(params[:branch]).no_return.not_equal_with_nofaktur.order("nofaktur ASC").group('nofaktur')
      
      unless faktur.empty?
        slice = faktur.map(&:nofaktur)
        ceui = []
        slice.each do |iceu|
          ceui << iceu[12,5].to_i
        end
        @sales_reports = (slice.first[12,5].to_i..slice.last[12,5].to_i).to_a - ceui
        @sales_report = SalesReport.new
      end
    end
  end

  # GET /sales_reports/1
  # GET /sales_reports/1.json
  def show
    @sales_report = SalesReport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sales_report }
    end
  end

  # GET /sales_reports/new
  # GET /sales_reports/new.json
  def new
    @sales_report = SalesReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sales_report }
    end
  end

  # GET /sales_reports/1/edit
  def edit
    @sales_report = SalesReport.find(params[:id])
  end

  # POST /sales_reports
  # POST /sales_reports.json
  def create
    @sales_report = SalesReport.new(params[:sales_report])
    @sales_report.tanggal = params[:sales_report]['tanggal'].to_i

    respond_to do |format|
      if @sales_report.save
        format.html { redirect_to sales_reports_path(:brand => params[:sales_report]['jenisbrgdisc'], :branch => params[:sales_report]['cabang_id'], :date => params[:sales_report]['tanggal'].to_i), notice: 'Sales report was successfully created.' }
        format.json { render json: @sales_report, status: :created, location: @sales_report }
      else
        format.html { render action: "new" }
        format.json { render json: @sales_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sales_reports/1
  # PUT /sales_reports/1.json
  def update
    @sales_report = SalesReport.find(params[:id])

    respond_to do |format|
      if @sales_report.update_attributes(params[:sales_report])
        format.html { redirect_to @sales_report, notice: 'Sales report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @sales_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_reports/1
  # DELETE /sales_reports/1.json
  def destroy
    @sales_report = SalesReport.find(params[:id])
    @sales_report.destroy

    respond_to do |format|
      format.html { redirect_to sales_reports_url }
      format.json { head :ok }
    end
  end
end
