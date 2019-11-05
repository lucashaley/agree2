# frozen_string_literal: true

module StatementsHelper
  include ActsAsTaggableOn::TagsHelper

  def get_statement_image(statement)
    if statement.image.attached?
      return statement.image
    else

    end
  end
end
