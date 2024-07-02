require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'associations' do
    it { should belong_to(:list) }
  end
end
