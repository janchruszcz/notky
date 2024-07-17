class Todo < ApplicationRecord
  belongs_to :list

  include RankedModel
  ranks :row_order, with_same: :list_id
end
