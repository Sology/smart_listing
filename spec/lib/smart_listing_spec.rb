require 'rails_helper'

module SmartListing
  describe Base do
    describe '#per_page' do

      context "when there is no specification in params or cookies" do
        it 'take first value in the page sizes' do
          SmartListing.config.global_options[:page_sizes] = [1]

          list = Base.new(:users, build_values)
          list.setup({}, {})

          expect(list.per_page).to eq 1
        end
      end

      context 'when a value is in params' do
        context 'when the value is in the list of page_sizes' do
          it 'set the per_page as in the value' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]

            list = Base.new(:users, build_values)
            list.setup({"users_smart_listing" => {per_page: "2"}}, {})

            expect(list.per_page).to eq 2
          end
        end

        context 'when the value is not in the list of page_sizes' do
          it 'take first value in the page sizes' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]

            list = Base.new(:users, build_values)
            list.setup({"users_smart_listing" => {per_page: "3"}}, {})

            expect(list.per_page).to eq 1
          end
        end
      end

      context 'when a value is in cookies' do
        context 'when the memorization is enabled' do
          it 'set the value in the cookies' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]
            SmartListing.config.global_options[:memorize_per_page] = true

            list = Base.new(:users, build_values)
            list.setup({}, {"users_smart_listing" => {per_page: "2"}})

            expect(list.per_page).to eq 2
          end
        end

        context 'when the memorization is disabled' do
          it 'take first value in the page sizes' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]
            SmartListing.config.global_options[:memorize_per_page] = false

            list = Base.new(:users, build_values)
            list.setup({}, {"users_smart_listing" => {per_page: "2"}})

            expect(list.per_page).to eq 1
          end
        end
      end

      context 'when the per page value is at 0' do
        context 'when the unlimited per page option is enabled' do
          it 'set the per page at 0' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]
            SmartListing.config.global_options[:unlimited_per_page] = true

            list = Base.new(:users, build_values)
            list.setup({"users_smart_listing" => {per_page: "0"}}, {})

            expect(list.per_page).to eq 0
          end
        end

        context 'when the unlimited per page option is disabled' do
          it 'take first value in the page sizes' do
            SmartListing.config.global_options[:page_sizes] = [1, 2]
            SmartListing.config.global_options[:unlimited_per_page] = false

            list = Base.new(:users, build_values)
            list.setup({}, {})

            expect(list.per_page).to eq 1
          end
        end
      end
    end

    def build_values
      Kaminari.paginate_array([])
    end
  end
end
