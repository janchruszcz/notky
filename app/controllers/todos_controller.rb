# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[edit update destroy]

  def new
    @todo = Todo.new
  end

  def edit; end

  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        format.turbo_stream { flash[:notice] = 'Todo was successfully created.' }
      else
        format.turbo_stream { flash[:alert] = 'Todo was not created.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.turbo_stream { flash[:notice] = 'Todo was successfully updated.' }
      else
        format.turbo_stream { flash[:alert] = 'Todo was not updated.' }
      end
    end
  end

  def destroy
    @todo.destroy!

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = 'Todo was successfully destroyed.' }
    end
  end

  def sort
    @todo = Todo.find(params[:id])
    @todo.update(row_order_position: params[:row_order_position], list_id: params[:list_id])
    head :no_content
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed, :due_date, :list_id)
  end
end
