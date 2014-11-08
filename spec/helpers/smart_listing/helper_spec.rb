require 'rails_helper'
require 'smart_listing/helper'

module SmartListing::Helper
  class UsersController < ApplicationController
    include ControllerExtensions

    attr_accessor :smart_listings

    def params
      { value: 'params' }
    end

    def cookies
      { value: 'cookies' }
    end

    def resource
      [1, 2]
    end
  end

  describe ControllerExtensions do
    describe "#smart_listing_create" do
      it "create a list with params and cookies" do
        controller = UsersController.new
        list = build_list

        expect(list).to receive(:setup).with(controller.params,
                                             controller.cookies)

        controller.smart_listing_create
      end

      it "assign a list in smart listings with the name" do
        controller = UsersController.new
        list = build_list

        controller.smart_listing_create

        expect(controller.smart_listings[:users]).to eq list
      end

      it 'return the collection of the list' do
        controller = UsersController.new
        collection1 = double
        collection2 = double
        build_list(collection: collection1)

        controller.smart_listing_create(collection: collection2)

        actual = controller.smart_listings[:users].collection
        expect(actual).to eq collection1
      end

      context 'when the collection if specified' do
        it 'use the collection sepecified' do
          controller = UsersController.new
          collection = double
          options = { collection: collection }
          build_list(options)

          expect(SmartListing::Base).to receive(:new).with(:users, collection, options)

          controller.smart_listing_create(options)
        end
      end

      context 'when there is no collection specified' do
        it 'use the resource method' do
          controller = UsersController.new
          options = { }
          build_list(options)

          expect(SmartListing::Base).to receive(:new).with(:users, controller.resource, options)

          controller.smart_listing_create(options)
        end
      end

      def build_list(options = {})
        double(collection: options[:collection], setup: nil).tap do |list|
          allow(SmartListing::Base).to receive(:new).and_return(list)
        end
      end
    end

    describe '#smart_listing' do
      it 'give the list with name' do
        controller = UsersController.new
        list = double
        controller.smart_listings = { test: list }
        expect(controller.smart_listing(:test)).to eq list
      end
    end
  end
end
