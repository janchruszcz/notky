class List < ApplicationRecord
    has_many :todos, dependent: :destroy
end
