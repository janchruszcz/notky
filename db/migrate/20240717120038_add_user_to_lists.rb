# frozen_string_literal: true

class AddUserToLists < ActiveRecord::Migration[7.1]
  def change
    add_reference :lists, :user, foreign_key: true
  end
end
