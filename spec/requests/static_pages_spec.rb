require 'spec_helper'

describe "Static pages" do

  subject { expect(page) }
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  describe "Home page" do

    it "should have the title Home" do
      visit '/static_pages/home'
      have_title("#{base_title} | Home")
    end
  end

  describe "Help page" do
    it "should have the title Help " do
      visit '/static_pages/help'
      have_title("#{base_title} | Help")
    end
  end

  describe "About page" do
    it "should have the title 'About Us'" do
      visit '/static_pages/about'
      have_title("#{base_title} | About Us")
    end
  end

  describe "Contact page" do
    it "should have the title 'Contact'" do
      visit '/static_pages/contact'
      have_title("#{base_title} | Contact")
    end
  end

end
