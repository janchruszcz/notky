# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Corkboard', type: :system do
  include ActionView::RecordIdentifier

  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(user, scope: :user)
  end

  describe 'Home page' do
    context 'when visiting the root path' do
      before { visit root_path }

      it 'displays the corkboard page' do
        expect(page).to have_content('notky.io')
      end

      it 'has the correct title' do
        expect(page).to have_title('notky.io')
      end
    end

    context 'with existing lists' do
      let!(:lists) { create_list(:list, 3, user:) }

      it 'displays all user lists' do
        visit root_path
        lists.each do |list|
          expect(page).to have_content(list.title)
        end
      end
    end

    describe 'List management' do
      it 'allows the user to create a new list' do
        visit root_path
        find('.add-list').click

        within '#modal' do
          fill_in 'list_title', with: 'Work'
          click_link_or_button 'Create List'
        end

        expect(page).to have_content('List created successfully')
        expect(page).to have_content('Work')
      end

      it 'allows the user to delete a list' do
        list = create(:list, user:)

        visit root_path
        within "#list_#{list.id}" do
          click_link_or_button('', class: 'delete-list')
        end

        expect(page).to have_content('List deleted successfully')
        expect(page).to have_no_content(list.title)
      end

      it 'allows the user to update a list title' do
        list = create(:list, user:)

        visit root_path
        within "#list_#{list.id}" do
          find('.edit-list').click
          fill_in 'list_title', with: 'Updated List Title'
          click_button 'Update List'
        end

        expect(page).to have_content('List updated successfully')
        expect(page).to have_content('Updated List Title')
      end
    end

    describe 'Todo management' do
      let!(:list) { create(:list, user:) }

      it 'displays todos for each list' do
        todos = create_list(:todo, 3, list:)
        visit root_path

        within "#list_#{list.id}" do
          todos.each do |todo|
            expect(page).to have_content(todo.title)
          end
        end
      end

      it 'allows the user to create a new todo' do
        visit root_path
        within "#list_#{list.id}" do
          find('.add-todo').click
        end

        expect(page).to have_content('Todo created successfully')
        expect(page).to have_content('New todo')
      end

      it 'allows the user to delete a todo' do
        todo = create(:todo, list:)

        visit root_path
        within "#todo_#{todo.id}" do
          accept_confirm { find('.delete-todo').click }
        end

        expect(page).to have_content('Todo deleted successfully')
        expect(page).to have_no_content(todo.title)
      end

      it 'allows the user to update a todo' do
        todo = create(:todo, list:)

        visit root_path
        within "#todo_#{todo.id}" do
          find('.edit-todo').click
          fill_in 'todo_title', with: 'Updated todo'
          click_button 'Update Todo'
        end

        expect(page).to have_content('Todo updated successfully')
        expect(page).to have_content('Updated todo')
      end

      it 'allows the user to mark a todo as completed' do
        todo = create(:todo, list:)

        visit root_path
        within "#todo_#{todo.id}" do
          find("input[type='checkbox']").set(true)
        end

        expect(page).to have_content('Todo updated successfully')
        expect(page).to have_css("#todo_#{todo.id}[data-completed='true']")
      end

      it 'allows the user to mark a completed todo as incomplete' do
        todo = create(:todo, list:, completed: true)

        visit root_path
        within "#todo_#{todo.id}" do
          find("input[type='checkbox']").set(false)
        end

        expect(page).to have_content('Todo updated successfully')
        expect(page).to have_no_css("#todo_#{todo.id}[data-completed='true']")
      end
    end

    describe 'Todo sorting', :js do
      let!(:list) { create(:list, user:) }
      let!(:todos) { create_list(:todo, 3, list:) }

      it 'allows the user to sort todos' do
        visit root_path

        within "#list_#{list.id}" do
          todos.each { |todo| expect(page).to have_content(todo.title) }

          first_todo = find('.todo:first-child')
          last_todo = find('.todo:last-child')

          first_todo.drag_to(last_todo)

          wait_for_ajax

          todos.each_with_index do |todo, index|
            expect(page).to have_css("#todo_#{todo.id}[data-row-order-position='#{index}']")
          end
        end
      end
    end
  end

  describe 'Performance' do
    it 'loads the home page quickly' do
      start_time = Time.now
      visit root_path
      load_time = Time.now - start_time

      expect(load_time).to be < 2.seconds
    end
  end

  describe 'Accessibility' do
    it 'has no accessibility violations' do
      visit root_path
      expect(page).to be_axe_clean
    end
  end
end
