class Report < ApplicationRecord
  enum kind: { adhominem: 0, nonsense: 1, inappropriate: 2 }

  belongs_to :statement, inverse_of: 'reports'
  belongs_to :voter, inverse_of: 'reports'
end
