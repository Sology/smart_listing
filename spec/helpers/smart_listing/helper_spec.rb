require 'rails_helper'
require 'smart_listing/helper'

module SmartListing::Helper
  class Controller < ApplicationController
    include ControllerExtensions

    attr_accessor :smart_listings

    def params
      { value: 'params' }
    end

    def cookies
      { value: 'cookies' }
    end
  end

  describe ControllerExtensions do
    describe "#smart_listing_create" do
      it "create a list with params and cookies" do
        controller = Controller.new
        collection = double
        list = build_list(collection: collection)

        expect(list).to receive(:setup).with(controller.params,
                                             controller.cookies)

        controller.smart_listing_create(:users, collection)
      end

      it "assign a list in smart listings with the name" do
        controller = Controller.new
        collection = double
        list = build_list(collection: collection)

        controller.smart_listing_create(:users, collection)

        expect(controller.smart_listings[:users]).to eq list
      end

      it 'return the collection of the list' do
        controller = Controller.new
        collection1 = double
        collection2 = double
        build_list(collection: collection1)

        controller.smart_listing_create(:users, collection2)

        actual = controller.smart_listings[:users].collection
        expect(actual).to eq collection1
      end

      def build_list(collection: )
        double(collection: collection, setup: nil).tap do |list|
          allow(SmartListing::Base).to receive(:new).and_return(list)
        end
      end
    end
  end
end
