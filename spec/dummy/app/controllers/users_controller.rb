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

  def resource
    @users ||= User.all
  end
end
