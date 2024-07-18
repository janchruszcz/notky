# frozen_string_literal: true

class List < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy

  include RankedModel
  ranks :row_order
end
