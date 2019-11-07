# frozen_string_literal: true

module StatementsHelper
  include ActsAsTaggableOn::TagsHelper

  def full_statement (content)
    return "I agree that #{content.gsub("'", %q(\\\'))}."
  end
end
