# frozen_string_literal: true

module ImagesHelper
  def font
    if Rails.env.development?
      font = 'helvetica-bold'
    elsif Rails.env.production?
      font = 'Nimbus-Sans-L-Bold'
    end
    font
  end

  def image_statement (content)
    text_statement = "I agree that #{content.gsub("'", %q(\\\'))}."
    text_statement
  end
end
