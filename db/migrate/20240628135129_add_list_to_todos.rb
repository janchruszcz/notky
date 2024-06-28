class AddListToTodos < ActiveRecord::Migration[7.1]
  def change
    add_reference :todos, :list, foreign_key: true
  end
end
