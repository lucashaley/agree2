# frozen_string_literal: true

module StatementsHelper
  include ActsAsTaggableOn::TagsHelper

  def full_statement (content)
    return "I agree that #{content.gsub("'", %q(\\\'))}."
  end

  def who_agrees (statement)
    count = statement.votes_for
    count = statement.vote_count

    if count > 2
      if current_user.present? and current_user.voted_for?(statement)
        return "You and #{number_to_human( count - 1 )} people agree that…"
      else
        return "#{number_to_human( count )} people agree that…"
      end
    elsif count == 2
      if current_user.present? and current_user.voted_for?(statement)
        return "You and 1 other person agree that…"
      else
        return "Two people agree that…"
      end
    elsif count == 1
      if current_user.present? and current_user.voted_for?(statement)
        return "You are the only person to agree that…"
      else
        return "One person agrees that…"
      end
    else
      return "Nobody yet agrees that…"
    end
  end

  def agree_button_css
    @css_string = 'btn btn-success btn-lg'
    if current_user
      @css_string += ' active' if current_user.voted_for?(@statement)
    end
    @css_string
  end
end
