# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo do
  describe 'associations' do
    it { is_expected.to belong_to(:list) }
  end
end
