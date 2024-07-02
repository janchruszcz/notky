require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'associations' do
    it { should have_many(:todos).dependent(:destroy) }
  end
end
