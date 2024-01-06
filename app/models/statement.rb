# frozen_string_literal: true

class Statement < ApplicationRecord
  has_closure_tree order: 'agree_count', numeric_order: true
  acts_as_taggable
  acts_as_voteable

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["agree_count", "author_id", "content", "created_at", "id", "id_value", "parent_id", "updated_at"]
  end

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
  has_one_attached :image_facebook
  has_one_attached :graph
  has_one_attached :image_graph

  # Callbacks
  before_create :clean_statement
  # around_save :save_statement
  # after_save :update_agree_count

  # Scopes
  scope :recent, -> { order(:created_at).reverse_order }
  scope :top, -> { order(:agree_count).reverse_order }
  # scope :voted_statements, ->(voter_id) {  }
  # scope :descendant_count, -> { order(:descendants.count).reverse_order}

  ASPECTS = {
    "square"  => "880x880",
    "2to1" => "880x440",
    "facebook" => "1200x630",
  }


  def clean_statement
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    # remove initial capital
    # content[0] = content[0].downcase

    # remove initial period
    content.sub!(/^[…]?/, '')
    # remove last punctuation
    content.sub!(/[?.!,;]?$/, '')

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end

  def save_statement
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    yield

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end

  # this can't be after save! What about associations?
  def update_agree_count
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    update_attribute(:agree_count, self.plusminus)
    # self.agree_count = self.plusminus

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
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

  def descendant_count
    self.descendants.count
  end

  def to_digraph_label
    content
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

  # private

  def build_images
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green
    if !image_2to1.attached?
      Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING 2to1 ------\n").red
      StatementCreateTwoToOneImageWorker.perform_async(hashid, content)
    end
    if !image_square.attached?
      Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING SQUARE ------\n").red
      StatementCreateSquareImageWorker.perform_async(hashid, content)
    end
    if !image_facebook.attached?
      Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING FACEBOOK ------\n").red
      StatementCreateFacebookImageWorker.perform_async(hashid, content)
    end
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end

  def self.rebuild_images!
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green
    Statement.find_each do |statement|
      if !statement.image_2to1.attached?
        Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING 2to1 ------\n").red
        StatementCreateTwoToOneImageWorker.perform_async(statement.hashid, statement.content)
      end
      if !statement.image_square.attached?
        Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING SQUARE ------\n").red
        StatementCreateSquareImageWorker.perform_async(statement.hashid, statement.content)
      end
      if !statement.image_facebook.attached?
        Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} MISSING FACEBOOK ------\n").red
        StatementCreateFacebookImageWorker.perform_async(statement.hashid, statement.content)
      end
    end
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end

  def self.rebuild_agrees!
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green
    Statement.find_each do |statement|
      statement.update_agree_count
    end
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end
end
