class Prompt < ApplicationRecord
  has_one :reply
  has_one :detail
  accepts_nested_attributes_for :detail, allow_destroy: true

  validates :title, presence: true, length: { minimum: 1 }
  validates :body, presence: true, length: { minimum: 5 }
end
