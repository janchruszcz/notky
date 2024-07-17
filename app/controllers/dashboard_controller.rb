class DashboardController < ApplicationController
  def index
    @lists = current_user.lists.rank(:row_order)
    # @todos = Todo.rank(:row_order)
  end
end
