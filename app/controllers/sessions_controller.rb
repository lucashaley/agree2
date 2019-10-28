# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

  def create
    Rails.logger.debug '-------------'
    Rails.logger.debug "sessions.create"
    Rails.logger.debug '-------------'

    voter = Voter.find_or_create_by!(fingerprint: params[:fingerprint])
    Rails.logger.debug '-------------'
    Rails.logger.debug voter.inspect
    Rails.logger.debug '-------------'

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
  end

  def destroy
    session[:voter_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
