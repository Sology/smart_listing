class UsersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    smart_listing_create :users, User.all, partial: 'users/list'
  end

  def sortable
    smart_listing_create :users, User.all, partial: 'users/sortable_list',
      default_sort: { name: 'desc' }
    render 'index'
  end
end
