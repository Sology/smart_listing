require 'rails_helper'

feature 'View a list of items' do
  fixtures :users
  scenario 'The user navigate through users', js: true do

    visit root_path
    #page_sizes => [3, 10]
    expect(page).to have_content("Betty")
    expect(page).to_not have_content("Edward")

    within(".pagination") { click_on "2" }

    expect(page).to have_content("Edward")
    expect(page).to_not have_content("Betty")
  end

  scenario "The user sort users", js: true do

    visit sortable_users_path

    find('.name a').click
    expect(find(:xpath, "//table/tbody/tr[1]")).to have_content("Aaron")
    expect(find(:xpath, "//table/tbody/tr[2]")).to have_content("Betty")

    find('.name a').click
    expect(find(:xpath, "//table/tbody/tr[1]")).to have_content("Sara")
    expect(find(:xpath, "//table/tbody/tr[2]")).to have_content("Robin")
  end

  scenario "The user search user", js: true do
    visit admin_users_path

    fill_in "filter", with: "ja"

    expect(page).to have_content("Jane")
    expect(page).to_not have_content("Aaron")

    fill_in "filter", with: "ni"

    expect(page).to_not have_content("Nicholas")
    expect(page).to_not have_content("Jane")
  end
end
