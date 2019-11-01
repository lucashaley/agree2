class Report < ApplicationRecord
  enum kind: {adhominem: 0, nonsense: 1, inappropriate: 2}

  belongs_to :statement
  belongs_to :voter
end
