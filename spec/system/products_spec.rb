require "rails_helper"

RSpec.describe "Products", type: :system do
  it "renders a page on :rack_test" do
    driven_by(:rack_test)
    visit root_path

    within("h1") do
      expect(page).to have_text("Products")
    end
  end


  it "renders a page on :headless_chrome", js: true do
    driven_by(:selenium, using: :headless_chrome) do |capabilities|
      capabilities.args << "--no-sandbox"
    end
    visit root_path

    within("h1") do
      expect(page).to have_text("Products")
    end
  end
end
