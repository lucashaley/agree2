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
end
