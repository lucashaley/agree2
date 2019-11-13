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
  has_many :reports, dependent: :destroy, inverse_of: 'statement'
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

  # Scopes
  scope :recent, -> { order(:created_at).reverse_order }
  scope :top, -> { order(:vote_count).reverse_order }

  ASPECTS = {
    "square"  => "880x880",
    "2to1" => "88x440"
  }


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
    update_attribute(:vote_count, self.votes_for)
    # self.vote_count = self.plusminus
    Rails.logger.debug "\n-------- update_vote_count end --------\n"
  end

  # putting 'self' beforehand turns this into a class method!
  # def self.top(count)
  #   Statement.plusminus_tally.limit(count)
  # end

  def top(count)
    # this just gets the direct children
    # children.plusminus_tally.limit(count)
    descendants.limit(count).reverse_order
  end

  def voted_ancestor(voter)
    # traverse ancestors to find voted_for
    self.ancestors.find { |ancestor|
      voter.voted_for?(ancestor)
    }
  end

  def voted_descendant(voter)
    self.descendants.find { |descendant|
      voter.voted_for?(descendant)
    }
  end

  def create_image(aspect)
    # an this be an instance method?
    convert = MiniMagick::Tool::Convert.new
    convert << '-page'
    convert << '0x0'
    convert << 'app/assets/images/weagreethat_twotoone.png'
    convert << '-page'
    convert << '+12+10'
    convert << '-size'
    convert << ASPECT[aspect]
    convert << '-font'
    convert << "#{font}"
    convert << "caption:#{image_statement(content)}"
    convert << '-layers'
    convert << 'mosaic'
    convert << "#{Rails.root.join('tmp')}/#{hashid}_#{aspect}.png"
    convert.call

    Statement.find(hashid).image_2to1.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}_#{aspect}.png"), filename: "#{hashid}_#{aspect}.png")
    # turn this into send method?
  end
end
