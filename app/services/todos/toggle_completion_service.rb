# frozen_string_literal: true

module Todos
  class ToggleCompletionService < BaseService
    # rubocop:disable Lint/MissingSuper
    def initialize(user:, todo_id:)
      @user = user
      @todo_id = todo_id
    end
    # rubocop:enable Lint/MissingSuper

    def call
      todo = find_todo

      return failure('Todo not found') unless todo

      if todo.update(completed: !todo.completed)
        success(todo)
      else
        failure(todo.errors.full_messages.join(', '))
      end
    end

    private

    def find_todo
      @user.todos.find_by(id: @todo_id)
    end
  end
end
