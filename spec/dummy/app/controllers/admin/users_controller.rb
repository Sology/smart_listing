class Admin::UsersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :find_user, except: [:index, :new, :create]
  before_filter :find_users, only: :index
  before_filter :build_user, only: [:new, :create]

  def index
    smart_listing_create partial: "admin/users/list"
    respond_to do |format|
      format.html
      format.js { render formats: :js }
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
  end

  def edit
  end

  def update
    @user.update_attributes(user_params)
  end

  def destroy
    @user.destroy
  end

  def change_name
    @user.update_attribute('name', 'Changed Name')
    render 'update'
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def find_users
    @users = User.all
  end

  def build_user
    @user = User.new
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def resource
    @users || @user
  end
  helper_method :resource
end
