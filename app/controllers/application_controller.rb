class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_global_search_variable

  def set_global_search_variable
    @q = Statement.ransack(search_params[:q])
  end

  helper_method :current_user
  def current_user
    if session[:voter_id]
      @current_user ||= Voter.find(session[:voter_id])
    else
      Rails.logger.debug "-------------"
      Rails.logger.debug "DID NOT FIND A USER"
      Rails.logger.debug "-------------"

      @current_user = nil
    end
  end

  def search_params
    params.permit(:utf8, :commit, q: [:content_cont]).to_h
  end
end
