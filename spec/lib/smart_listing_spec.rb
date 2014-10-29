require 'rails_helper'

module SmartListing
  describe Base do
    describe '#per_page' do

      context "when there is no specification in params or cookies" do
        it 'take first value in the page sizes' do
          options = {page_sizes: [1]}
          list = build_list(options: options)

          list.setup({}, {})

          expect(list.per_page).to eq 1
        end
      end

      context 'when a value is in params' do
        context 'when the value is in the list of page_sizes' do
          it 'set the per_page as in the value' do
            options = {page_sizes: [1, 2]}
            list = build_list(options: options)

            list.setup({"users_smart_listing" => {per_page: "2"}}, {})

            expect(list.per_page).to eq 2
          end
        end

        context 'when the value is not in the list of page_sizes' do
          it 'take first value in the page sizes' do
            options = {page_sizes: [1, 2]}
            list = build_list(options: options)

            list.setup({"users_smart_listing" => {per_page: "3"}}, {})

            expect(list.per_page).to eq 1
          end
        end
      end

      context 'when a value is in cookies' do
        context 'when the memorization is enabled' do
          it 'set the value in the cookies' do
            options = {page_sizes: [1, 2], memorize_per_page: true}
            list = build_list(options: options)

            list.setup({}, {"users_smart_listing" => {per_page: "2"}})

            expect(list.per_page).to eq 2
          end
        end

        context 'when the memorization is disabled' do
          it 'take first value in the page sizes' do
            options = {page_sizes: [1, 2], memorize_per_page: false}
            list = build_list(options: options)

            list.setup({}, {"users_smart_listing" => {per_page: "2"}})

            expect(list.per_page).to eq 1
          end
        end
      end

      context 'when the per page value is at 0' do
        context 'when the unlimited per page option is enabled' do
          it 'set the per page at 0' do
            options = {page_sizes: [1, 2], unlimited_per_page: true}
            list = build_list(options: options)

            list.setup({"users_smart_listing" => {per_page: "0"}}, {})

            expect(list.per_page).to eq 0
          end
        end

        context 'when the unlimited per page option is disabled' do
          it 'take first value in the page sizes' do
            options = {page_sizes: [1, 2], unlimited_per_page: false}
            list = build_list(options: options)

            list.setup({}, {})

            expect(list.per_page).to eq 1
          end
        end
      end

      context 'when the memorization of per page is enabled' do
        it 'save the perpage in the cookies' do
          options = {page_sizes: [1], memorize_per_page: true}
          list = build_list(options: options)
          cookies = {}

          list.setup({}, cookies)

          expect(cookies["users_smart_listing"][:per_page]).to eq 1
        end
      end
    end

    describe '#sort' do
      context 'when there is a value in params' do
        it 'set sort with the given value' do
          list = build_list
          params = {"users_smart_listing"=>{sort: {"name"=>"asc"}}}

          list.setup(params, {})

          expect(list.sort).to eq 'name' => 'asc'
        end
      end

      context 'when there is no value in params' do
        it 'take the value in options' do
          options = { default_sort: { 'email' => 'asc' } }
          list = build_list(options: options)

          list.setup({}, {})

          expect(list.sort).to eq 'email' => 'asc'
        end
      end
    end

    describe '#collection' do
      context 'when the collection is not an array' do
        it 'sort the collection by the given option' do
          user1 = User.create(name: '1')
          user2 = User.create(name: '2')
          options = { default_sort: { 'name' => 'desc' } }
          list = build_list(options: options)

          list.setup({},{})

          expect(list.collection.first).to eq user2
          expect(list.collection.last).to eq user1
        end

        it 'give only the given number per page' do
          user1 = User.create(name: '1')
          user2 = User.create(name: '2')
          options = { page_sizes: [1] }
          list = build_list(options: options)

          list.setup({},{})

          expect(list.collection).to include user1
          expect(list.collection).to_not include user2
        end

        it 'give the right page' do
          user1 = User.create(name: '1')
          user2 = User.create(name: '2')
          options = { page_sizes: [1] }
          list = build_list(options: options)

          list.setup({"users_smart_listing" => {page: "2"}}, {})

          expect(list.collection).to include user2
          expect(list.collection).to_not include user1
        end
      end
    end

    def build_values
      User.all
    end

    def build_list(options: {})
      Base.new(:users, build_values, options)
    end
  end
end
