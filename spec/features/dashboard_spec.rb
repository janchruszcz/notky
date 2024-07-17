require 'rails_helper'

RSpec.describe 'Corkboard', type: :feature do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  describe 'GET /' do
    it 'displays the corkboard page' do
      visit root_path
      expect(page).to have_content('notky.io')
    end

    it 'displays a list of the users lists' do
      create_list(:list, 3, user:, title: 'List')
      lists = List.all

      visit root_path
      lists.each do |list|
        expect(page).to have_content(list.title)
      end
    end

    it 'allows the user to create a new list' do
      visit root_path
      click_button 'add-list'

      fill_in 'list_title', with: 'My New List'
      click_button 'Create List'

      expect(page).to have_content('List created successfully')
      expect(page).to have_content('My New List')
    end

    it 'allows the user to delete a list' do
      list = create(:list, user:)

      visit root_path
      within "#list_#{list.id}" do
        click_button "delete-list-#{list.id}"
      end

      expect(page).to have_content('List deleted successfully')
      expect(page).not_to have_content(list.title)
    end
  end
end
