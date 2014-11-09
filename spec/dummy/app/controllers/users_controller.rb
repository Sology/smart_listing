class UsersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    smart_listing_create partial: 'users/list'
  end

  def sortable
    smart_listing_create partial: 'users/sortable_list',
      default_sort: { name: 'desc' }
    render 'index'
  end

  def searchable
    users = User.all
    users = users.search(params[:filter]) if params[:filter]
    @users = smart_listing_create collection: users, partial: 'users/searchable_list',
      default_sort: { name: 'desc' }
  end

  private

  def smart_listing_resource
    @user ||= params[:id] ? User.find(params[:id]) : User.new(params[:user])
  end
  helper_method :smart_listing_resource

  def smart_listing_collection
    @users ||= User.all
  end
  helper_method :smart_listing_collection
end
