# frozen_string_literal: true

class Statement < ApplicationRecord
  has_closure_tree order: 'vote_count', numeric_order: true
  acts_as_taggable
  acts_as_voteable

  # Includes
  # https://github.com/jcypret/hashid-rails
  include Hashid::Rails

  # Validations
  validates :content, presence: true, uniqueness: { case_sensitive: false }

  # Relationships
  belongs_to :author, class_name: 'Voter'
  accepts_nested_attributes_for :children
  has_many :reports, dependent: :destroy
  accepts_nested_attributes_for :reports

  # ActiveStorage
  # https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html
  has_one_attached :statement_image
  has_one_attached :image_2to1
  has_one_attached :image_square

  # Callbacks
  before_create :clean_statement
  # around_save :save_statement
  # after_save :update_vote_count

  def clean_statement
    Rails.logger.debug "\n-------- CLEAN_STATEMENT Start --------\n"

    # remove initial capital
    # content[0] = content[0].downcase

    # remove last punctuation
    content.sub!(/[?.!,;]?$/, '')

    Rails.logger.debug "\n-------- CLEAN_STATEMENT End --------\n"
  end

  def save_statement
    Rails.logger.debug "\n-------- SAVE_STATEMENT Start --------\n"

    yield

    Rails.logger.debug "\n-------- SAVE_STATEMENT End --------\n"
  end

  # this can't be after save! What about associations?
  def update_vote_count
    Rails.logger.debug "\n-------- update_vote_count start --------\n"
    update_attribute(:vote_count, self.plusminus)
    # self.vote_count = self.plusminus
    Rails.logger.debug "\n-------- update_vote_count end --------\n"
  end

  # putting 'self' beforehand turns this into a class method!
  def self.top(count)
    Statement.plusminus_tally.limit(count)
  end

  def top(count)
    # this just gets the direct children
    # children.plusminus_tally.limit(count)
    descendants.limit(count).reverse
  end
end
