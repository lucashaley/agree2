# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_global_search_variable

  def set_global_search_variable
    @q = Statement.ransack(search_params[:q])
  end

  helper_method :current_voter
  def current_voter
    if session[:voter_id]
      @current_voter ||= Voter.find(session[:voter_id])
    else
      Rails.logger.error Rainbow("\n\n-- #{self.class}:#{(__method__)} DID NOT FIND A VOTER ------\n").red.bright

      @current_voter = nil
    end
  end

  def search_params
    params.permit(:utf8, :commit, q: [:content_cont]).to_h
  end
end
