# frozen_string_literal: true

# Sanitizes string inputs to prevent XSS and other injection attacks
# Include this module in models that accept user input
module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_string_attributes
  end

  private

  # Attributes to exclude from sanitization (e.g., passwords, encrypted fields)
  def sanitization_excluded_attributes
    %w[encrypted_password password password_confirmation reset_password_token]
  end

  def sanitize_string_attributes
    self.class.attribute_names.each do |attr|
      next if sanitization_excluded_attributes.include?(attr)

      value = send(attr)
      next unless value.is_a?(String)

      sanitized = sanitize_value(value)
      send("#{attr}=", sanitized)
    end
  end

  def sanitize_value(value)
    # Strip whitespace from beginning and end
    value = value.strip

    # Remove null bytes
    value = value.delete("\u0000")

    # Sanitize HTML to prevent XSS (removes all tags and attributes)
    ActionController::Base.helpers.sanitize(value, tags: [], attributes: [])
  end
end
