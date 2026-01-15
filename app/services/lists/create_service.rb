# frozen_string_literal: true

module Lists
  class CreateService < BaseService
    # rubocop:disable Lint/MissingSuper
    def initialize(user:, params:)
      @user = user
      @params = params
    end
    # rubocop:enable Lint/MissingSuper

    def call
      list = @user.lists.build(@params)

      if list.save
        success(list)
      else
        failure(list.errors.full_messages.join(', '))
      end
    end
  end
end
