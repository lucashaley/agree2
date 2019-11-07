# frozen_string_literal: true

class Statement < ApplicationRecord
  has_closure_tree
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
  has_one_attached :image_twotoone
  has_one_attached :image_square

  # Callbacks
  before_create :clean_statement
  around_save :save_statement

  def clean_statement
    Rails.logger.debug "\n-------- CLEAN_STATEMENT Start --------\n"

    # remove initial capital
    content[0] = content[0].downcase

    # remove last punctuation
    content.sub!(/[?.!,;]?$/, '')

    Rails.logger.debug "\n-------- CLEAN_STATEMENT End --------\n"
  end

  def save_statement
    Rails.logger.debug "\n-------- SAVE_STATEMENT Start --------\n"

    yield

    Rails.logger.debug "\n-------- SAVE_STATEMENT End --------\n"
  end
end
