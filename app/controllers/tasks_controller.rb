class TasksController < ApplicationController

  before_action :load_user
  before_action :set_project, only: [:create]
  before_action :set_task, only: [:update]
  before_action :set_task_period, only: [:pause, :stop]
  before_action :check_user!, only: [:pause, :stop, :update]
    
  def index
    @task = Task.new
    if @user.tasks.empty?
      @task.project = Project.new
    else
      @task.project = @user.tasks.order("updated_at DESC").first.project unless @user.tasks.empty?
    end
  end

  def list
  end

  def create
    @task = @project.tasks.create(nil)
    @task_period = @task.task_periods.first
    respond_to do |format|
      format.js 
    end
  end

  def update
    @task.task_periods.create(nil)
    @task_period = @task.task_periods.find { |t| t.started? }
    respond_to do |format|
      format.js 
    end
  end

  def stop
    stop_task
    filtered_params = task_params
    client_name = filtered_params.delete(:client)
    project_name = filtered_params.delete(:project)

    @task.assign_attributes(filtered_params)
    if project_name != @task.project.name
      @task.project = Project.find_or_create_by(name: project_name, user: @user)
    end

    if @task.project.client.nil? || (client_name != @task.project.client.name)
      @task.project.client = Client.find_or_create_by(name: client_name, user: @user)
      @task.project.save
    end
    @task.save

    redirect_to "/#{@user.username}"
  end

  def pause
    stop_task
    @task_period = TaskPeriod.new
    respond_to do |format|
      format.js 
    end
  end

  private 

  def load_user
    @user = User.find_by_username(params[:user])
    create_user if @user.nil?
  end

  def create_user
    @user = User.create(username: params[:user])
  end

  def set_project
    @project = Project.where(user: @user, name: params[:project]).first
    create_project if @project.nil?
  end

  def create_project
    @project = Project.create(user: @user, name: params[:project])
  end

  def set_task_period    
    @task_period = TaskPeriod.find(params[:id])
    @task = @task_period.task
    true
  end

  def check_user!
      redirect_to "/#{@user.username}" unless @task.project.user == @user
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def stop_task
    @task_period.close    
  end

  def task_params
    params.require(:task).permit(:description, :billable, :client, :project) 
  end

end
