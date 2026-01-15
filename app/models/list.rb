# frozen_string_literal: true

class List < ApplicationRecord
  include Sanitizable

  belongs_to :user
  has_many :todos, dependent: :destroy

  include RankedModel
  ranks :row_order

  validates :title, presence: true, length: { maximum: 100 }
end
