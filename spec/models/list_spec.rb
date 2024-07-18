# frozen_string_literal: true

require 'rails_helper'

RSpec.describe List do
  describe 'associations' do
    it { is_expected.to have_many(:todos).dependent(:destroy) }
    it { is_expected.to belong_to(:user) }
  end
end
