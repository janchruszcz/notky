# frozen_string_literal: true

class Todo < ApplicationRecord
  include Sanitizable

  belongs_to :list

  include RankedModel
  ranks :row_order, with_same: :list_id

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  # Scopes for filtering todos
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :overdue, -> { incomplete.where(due_date: ...Time.current) }
  scope :due_today, -> { incomplete.where(due_date: Time.current.all_day) }
  scope :due_soon, -> { incomplete.where(due_date: Time.current..3.days.from_now) }
  scope :with_due_date, -> { where.not(due_date: nil) }

  def overdue?
    due_date.present? && due_date < Time.current && !completed?
  end

  def due_soon?
    due_date.present? && due_date <= 3.days.from_now && due_date > Time.current && !completed?
  end
end
