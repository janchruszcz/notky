# frozen_string_literal: true

class FlashMessageComponent < ViewComponent::Base
  TYPES = {
    notice: {
      bg_color: 'bg-green-50',
      text_color: 'text-green-800',
      icon_color: 'text-green-400',
      icon: 'check-circle'
    },
    alert: {
      bg_color: 'bg-red-50',
      text_color: 'text-red-800',
      icon_color: 'text-red-400',
      icon: 'x-circle'
    }
  }.freeze

  def initialize(type:, message:)
    super()
    @type = type.to_sym
    @message = message
  end

  def type_config
    TYPES[@type] || TYPES[:notice]
  end

  def bg_color
    type_config[:bg_color]
  end

  def text_color
    type_config[:text_color]
  end

  def icon_color
    type_config[:icon_color]
  end

  def icon_name
    type_config[:icon]
  end

  def render?
    @message.present?
  end
end
