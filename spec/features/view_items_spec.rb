require 'rails_helper'

feature 'View a list of items' do
  scenario 'The user navigate through users', js: true do
    11.times { |i| User.create!(name: "Name#{i}", email: "Email#{i}") }

    visit root_path

    expect(page).to have_content("Name0")
    expect(page).to_not have_content("Name10")

    within(".pagination") { click_on "2" }

    expect(page).to have_content("Name10")
    expect(page).to_not have_content("Name0")
  end

  scenario "The user sort users", js: true do
    User.create(name: "aaaName", email: "bbbEmail")
    User.create(name: "bbbName", email: "aaaEmail")

    visit sortable_users_path

    expect(find(:xpath, "//table/tbody/tr[1]")).to have_content("bbbName")
    expect(find(:xpath, "//table/tbody/tr[2]")).to have_content("aaaName")

    find('.name a').click

    expect(find(:xpath, "//table/tbody/tr[1]")).to have_content("aaaName")
    expect(find(:xpath, "//table/tbody/tr[2]")).to have_content("bbbName")
  end
end
