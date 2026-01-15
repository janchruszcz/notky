# frozen_string_literal: true

module Todos
  class CreateService < BaseService
    # rubocop:disable Lint/MissingSuper
    def initialize(user:, params:)
      @user = user
      @params = params
    end
    # rubocop:enable Lint/MissingSuper

    def call
      list = @user.lists.find_by(id: @params[:list_id])

      return failure('List not found') unless list

      todo = list.todos.build(@params.except(:list_id))

      if todo.save
        success(todo)
      else
        failure(todo.errors.full_messages.join(', '))
      end
    end
  end
end
