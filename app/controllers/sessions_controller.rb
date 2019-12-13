# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

  def create
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    voter = Voter.find_or_create_by!(fingerprint: params[:fingerprint])

    if voter
      session[:voter_id] = voter.id
      # redirect_to root_url, notice: "Recognized!"
    else
      # flash.now[:alert] = "Not Recognized!"
      # render "new"
      # render "statements/show", notice: "Not Recognized!"
      # we need to create a new voter

      redirect_back fallback_location: statements_url
    end

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end

  def destroy
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    session[:voter_id] = nil
    redirect_to root_url, notice: 'Logged out!'

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end
end
