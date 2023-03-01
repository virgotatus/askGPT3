class Idea < ApplicationRecord
  validates :city, presence: true
  validates :thing, presence: true
  validates :oblique, presence: true
  validates :style, presence: true
end
