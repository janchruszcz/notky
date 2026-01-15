# frozen_string_literal: true

module Lists
  class ReorderService < BaseService
    # rubocop:disable Lint/MissingSuper
    def initialize(user:, list_id:, position:)
      @user = user
      @list_id = list_id
      @position = position
    end
    # rubocop:enable Lint/MissingSuper

    def call
      list = @user.lists.find_by(id: @list_id)

      return failure('List not found') unless list

      if list.update(row_order_position: @position)
        success(list)
      else
        failure(list.errors.full_messages.join(', '))
      end
    end
  end
end
