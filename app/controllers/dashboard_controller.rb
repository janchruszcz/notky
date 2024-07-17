class DashboardController < ApplicationController
  def index
    @lists = List.rank(:row_order)
    @todos = Todo.rank(:row_order)
  end
end
