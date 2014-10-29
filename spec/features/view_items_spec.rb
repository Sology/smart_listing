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
end
