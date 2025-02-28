class TodoController < ApplicationController
  before_action :find_todo, only: %i[update destroy]

  def index
    todos = Todo.all
    render json: { todos: TasksRepresenter.new(todos).as_json, message: 'Todos retrieved successfully' }, status: :ok
  end

  def create
    return render json: { error: 'Missing todo parameters' }, status: :bad_request unless params[:todo]

    todo = Todo.new(todo_params)
    if todo.save
      render json: { todo: TaskRepresenter.new(todo).as_json, message: 'Todo created successfully' }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.done
      render json: { todo: TaskRepresenter.new(@todo).as_json, message: 'Todo is already completed' }, status: :ok
    elsif @todo.update(done: true)
      render json: { todo: TaskRepresenter.new(@todo).as_json, message: 'Todo marked as completed' }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo.done
      render json: { todo: TaskRepresenter.new(@todo).as_json, error: 'Completed todos cannot be deleted' }, status: :forbidden
    elsif @todo.destroy
      render json: { message: 'Todo deleted successfully' }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_todo
    @todo = Todo.find_by(id: params[:id])
    render json: { error: 'Todo not found' }, status: :not_found if @todo.nil?
  end

  def todo_params
    params.require(:todo).permit(:title, :description)
  end
end
