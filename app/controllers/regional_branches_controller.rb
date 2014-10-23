class RegionalBranchesController < ApplicationController
  
  def create
    regional = Regional.find(params[:regional])
    @cabangs = Cabang.find(params[:cabang_ids])
    @cabangs.each do |cabang|
      regional.regional_branches.create(regional_id: params[:regional], 
      cabang_id: cabang.id, brand_id: params[:brand_id])
    end
    flash[:notice] = "Added branch."
    redirect_to list_cabang_regionals_path(regional: params[:regional])
  end
  
  def destroy
    regional = Regional.find(params[:regional_id])
    @regional_branches = regional.regional_branches.where(cabang_id: params[:cabang_id])
    @regional_branches.destroy
    flash[:notice] = "Removed friendship."
    redirect_to current_user
  end
end
