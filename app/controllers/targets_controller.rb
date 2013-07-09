class TargetsController < ApplicationController
  def monthly_target_type
		session[:monthly_target_type] = nil
		session[:monthly_target_channel] = nil
		session[:monthly_target_type] = params[:monthly_target_type] if params[:monthly_target_type].present?
		redirect_to targets_monthly_target_channel_path if session[:monthly_target_type] == 'customer'
		redirect_to monthly_targets_path if session[:monthly_target_type] == 'branch'
  end

  def monthly_target_channel
		session[:monthly_target_channel] = params[:monthly_target_channel] if params[:monthly_target_channel].present?
		redirect_to monthly_retails_path if session[:monthly_target_channel] == 'retail'
		redirect_to monthly_targets_path if session[:monthly_target_channel] != 'retail' && session[:monthly_target_channel].present?
  end

  def monthly_target_customer
  end

end
