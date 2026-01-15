# frozen_string_literal: true

class List < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy

  include RankedModel
  ranks :row_order

  validates :title, presence: true, length: { maximum: 100 }

  before_validation :strip_title

  private

  def strip_title
    self.title = title&.strip
  end
end
