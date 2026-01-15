# frozen_string_literal: true

module Todos
  class ReorderService < BaseService
    # rubocop:disable Lint/MissingSuper
    def initialize(user:, todo_id:, position:, list_id: nil)
      @user = user
      @todo_id = todo_id
      @position = position
      @list_id = list_id
    end
    # rubocop:enable Lint/MissingSuper

    def call
      todo = find_todo

      return failure('Todo not found') unless todo

      attrs = { row_order_position: @position }
      attrs[:list_id] = @list_id if @list_id.present? && valid_list?

      if todo.update(attrs)
        success(todo)
      else
        failure(todo.errors.full_messages.join(', '))
      end
    end

    private

    def find_todo
      @user.todos.find_by(id: @todo_id)
    end

    def valid_list?
      @user.lists.exists?(id: @list_id)
    end
  end
end
