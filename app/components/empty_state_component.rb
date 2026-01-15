# frozen_string_literal: true

class EmptyStateComponent < ViewComponent::Base
  def initialize(title:, description: nil, icon: 'folder-open')
    super()
    @title = title
    @description = description
    @icon = icon
  end

  attr_reader :title, :description, :icon
end
