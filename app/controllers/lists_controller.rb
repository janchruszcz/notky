# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :set_list, only: %i[edit update destroy]

  def new
    @list = List.new
  end

  def edit; end

  def create
    @list = List.new(list_params)

    respond_to do |format|
      if @list.save
        format.turbo_stream { flash[:notice] = 'List created successfully.' }
      else
        format.turbo_stream { flash[:alert] = 'List was not created.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @list.update(list_params)
        format.turbo_stream { flash[:notice] = 'List updated successfully.' }
      else
        format.turbo_stream { flash[:alert] = 'List was not updated.' }
      end
    end
  end

  def destroy
    @list.destroy!

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = 'List deleted successfully.' }
    end
  end

  def sort
    @list = List.find(params[:id])
    @list.update(row_order_position: params[:row_order_position])
    head :no_content
  end

  def list
    @todos = @list.todos.rank(:row_order)
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:title, :user_id)
  end
end
