class List < ApplicationRecord
  has_many :todos, dependent: :destroy

  include RankedModel
  ranks :row_order
end
