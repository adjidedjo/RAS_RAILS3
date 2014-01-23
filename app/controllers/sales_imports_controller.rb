class SalesImportsController < ApplicationController
  def new
    @sales_import = SalesImport.new
  end

  def create
    @sales_import = SalesImport.new(params[:sales_import])
    if @sales_import.save
      redirect_to new_sales_import_path, notice: "Imported sales report successfully."
    else
      render :new
    end
  end
end
