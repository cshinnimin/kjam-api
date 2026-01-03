class Game < ApplicationRecord
  belongs_to :home, class_name: 'Team'
  belongs_to :away, class_name: 'Team'

  validates :home, presence: true
  validates :away, presence: true
end
