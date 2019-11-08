# frozen_string_literal: true

module StatementsHelper
  include ActsAsTaggableOn::TagsHelper

  def full_statement (content)
    return "I agree that #{content.gsub("'", %q(\\\'))}."
  end

  def who_agrees (statement)
    if statement.votes_for > 2
      if current_user.present? and current_user.voted_for?(statement)
        return "You and #{number_to_human( statement.votes_for - 1 )} people agree that…"
      else
        return "#{number_to_human( statement.votes_for )} people agree that…"
      end
    elsif statement.votes_for == 2
      if current_user.present? and current_user.voted_for?(statement)
        return "You and 1 other person agree that…"
      else
        return "Two people agree that…"
      end
    elsif statement.votes_for == 1
      if current_user.present? and current_user.voted_for?(statement)
        return "You are the only person to agree that…"
      else
        return "One person agrees that…"
      end
    else
      return "Nobody yet agrees that…"
    end
  end
end
