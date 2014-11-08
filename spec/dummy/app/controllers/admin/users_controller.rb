class Admin::UsersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :find_user, except: [:index, :new, :create]

  def index
    smart_listing_create User.all, partial: "admin/users/list"
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

  def user_params
    params.require(:user).permit(:name, :email)
  end

end
