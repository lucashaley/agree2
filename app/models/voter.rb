class Voter < ApplicationRecord
  acts_as_voter
  # The following line is optional, and tracks karma (up votes) for questions this user has submitted.
  # Each question has a submitter_id column that tracks the user who submitted it.
  # The option :weight value will be multiplied to any karma from that voteable model (defaults to 1).
  # You can track any voteable model.
  # has_karma :statements, :as => :submitter, :weight => 0.5
  has_karma :statements, as: :submitter, weight: 0.5
  # Karma by default is only calculated from upvotes. If you pass an array to the weight option,
  # you can count downvotes as well (below, downvotes count for half as much karma against you):
  # has_karma :statements, :as => :submitter, :weight => [1, 0.5]
  has_karma :statements, as: :submitter, weight: [1, 0.5]

  has_many :reports, inverse_of: 'voter'

  # def vote_for_statement (statement, ancestor, descendant)
  #   Rails.logger.debug "\n\n---- vote_for_statement ----\n\n"
  #
  #   statement.ancestors.scoping do
  #     Rails.logger.debug "Scoping count: #{statement.votes_count}\n\n"
  #     # Rails.logger.debug "Voted for: #{Statement.tally.inspect}\n\n"
  #   end
  #   # go up through statements
  #   Rails.logger.debug statement.ancestors.votes_count
  #   # go down through statements
  #
  #   vote_for(statement)
  # end
end
