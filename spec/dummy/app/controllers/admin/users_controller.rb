class Admin::UsersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_action :find_user, except: [:index, :new, :create]

  def index
    @users = User.all
    @users = @users.like(params[:filter]) if params[:filter]
    @users = @users.by_boolean if params[:boolean] == "1"
    smart_listing_create(:users, @users, partial: "admin/users/list")

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

  def smart_listing_resource
    @user ||= params[:id] ? User.find(params[:id]) : User.new(params[:user])
  end
  helper_method :smart_listing_resource

  def smart_listing_collection
    @users ||= User.all
  end
  helper_method :smart_listing_collection

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
