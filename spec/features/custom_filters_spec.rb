require 'rails_helper'

feature 'Combine custom filtering' do
  fixtures :users

  scenario 'The user search user, change pagination and change page', js: true do

    visit admin_users_path
    #page_sizes => [3, 10]
    within(".pagination-per-page") { click_on "10" }
    expect(page).to have_selector('tr.editable', count: 8)
    fill_in "filter", with: "test"
    expect(page).to have_selector('tr.editable', count: 4)
    within(".pagination-per-page") { click_on "3" }
    within(".pagination") { click_on "2" }
    expect(page).to have_selector('tr.editable', count: 1)

  end

  scenario 'The user sort users and change page', js: true do

    visit admin_users_path
    find('.name a.sortable').click
    expect(page).to have_content("Aaron")
    expect(page).to_not have_content("Jane")
    within(".pagination") { click_on "2" }
    expect(page).to have_content("Jane")
    expect(page).to_not have_content("Aaron")

  end

  scenario 'The user combine filters', js: true do

    visit admin_users_path
    fill_in "filter", with: "email"
    find('input#boolean').click
    expect(page).to have_selector('tr.editable', count: 2)

  end

  scenario 'The user combine filters and sort users', js: true do

    visit admin_users_path
    fill_in "filter", with: "test"
    find('input#boolean').click
    wait_for_ajax
    expect(page).to have_selector('tr.editable', count: 2)
    click_link 'Name'
    expect(page).to have_selector('tr.editable', count: 2)
    expect(page.find(:css, "tbody > tr:nth-child(1)")).to have_content("Edward")
    expect(page.find(:css, "tbody > tr:nth-child(2)")).to have_content("Robin")

  end

  scenario 'The user combine filters, sort and change page', js: true do

    visit admin_users_path
    check 'boolean'
    wait_for_ajax
    expect(find(:css, '.email a.sortable')[:href]).to include("boolean")
    click_link 'Email'
    expect(page.find(:css, "tbody > tr:nth-child(2)")).to have_content("Lisa")
    within(".pagination") { click_on "2" }
    expect(page.find(:css, "tbody > tr:nth-child(1)")).to have_content("Robin")
    expect(page.find(:css, '.count')).to have_content("4")

  end

end
