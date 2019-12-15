# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    if valid_page?
      render template: "pages/#{params[:page]}"
    else
      Rails.logger.error Rainbow("\n\n-- #{self.class}:#{(__method__)} NOT FOUND ------\n").red.bright
      render file: 'public/404.html', status: :not_found
    end
  end

  def error_404
    render status: 404
  end

  private

  def valid_page?
    filename = Zaru.sanitize! params[:page]
    File.exist?(Pathname.new(Rails.root + "app/views/pages/#{filename}.html.erb"))
  end
end
