# frozen_string_literal: true

module StatementsHelper
  include ActsAsTaggableOn::TagsHelper

  def full_statement (content)
    return "I agree that #{content}."
  end

  def ellipsis_statement (content)
    if content.present?
      return "…#{content}."
    else
      return '…'
    end
  end

  def who_agrees (statement)
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green.bright

    # count = statement.votes_for
    count = statement.agree_count
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} count=#{count} ------\n").blue

    if count > 2
      if current_voter.present? and current_voter.voted_for?(statement)
        return "You and #{number_to_human( count - 1 )} people agree that…"
      else
        return "#{number_to_human( count )} people agree that…"
      end
    elsif count == 2
      if current_voter.present? and current_voter.voted_for?(statement)
        return "You and 1 other person agree that…"
      else
        return "Two people agree that…"
      end
    elsif count == 1
      if current_voter.present? and current_voter.voted_for?(statement)
        return "You are the only person to agree that…"
      else
        return "One person agrees that…"
      end
    else
      return "Nobody yet agrees that…"
    end

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred.bright
  end

  def agree_button_css
    @css_string = 'btn btn-success btn-lg'
    if current_voter
      @css_string += ' active' if current_voter.voted_for?(@statement)
    end
    @css_string
  end
end
