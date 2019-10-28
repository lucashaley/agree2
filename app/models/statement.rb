class Statement < ApplicationRecord
  has_closure_tree
  acts_as_taggable
  acts_as_voteable

  validates :content, presence: true

  belongs_to :author, class_name: 'Voter'
  # belongs_to :parent, class_name: "Statement", optional: true
  # has_many :children, class_name: "Statement", foreign_key: "parent_id"
  accepts_nested_attributes_for :children

  has_many :reports

  # https://github.com/jcypret/hashid-rails
  include Hashid::Rails

  # ActiveStorage
  # https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html
  has_one_attached :statement_image

  before_create :clean_statement

  def clean_statement
    Rails.logger.debug "\n-------- CLEAN_STATEMENT --------"
    # remove initial capital
    self.content[0] = self.content[0].downcase

    # remove last punctuation
    content.sub!(/[?.!,;]?$/, '')
  end
end
