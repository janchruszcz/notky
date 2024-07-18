# frozen_string_literal: true

class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description
      t.boolean :completed
      t.datetime :due_date

      t.timestamps
    end
  end
end
