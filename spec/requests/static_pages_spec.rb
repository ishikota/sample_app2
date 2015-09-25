require 'spec_helper'

describe "Static pages" do

  subject { page }
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  describe "Home page" do
    before { visit '/static_pages/home' }
    it { should  have_title("#{base_title}") }
    it { should_not have_title(" | Home") }
  end

  describe "Help page" do
    before { visit '/static_pages/help' }
    it { should have_title("#{base_title} | Help") }
  end

  describe "About page" do
    before { visit '/static_pages/about' }
    it { should have_title("#{base_title} | About Us") }
  end

  describe "Contact page" do
    before { visit '/static_pages/contact' }
    it { should have_title("#{base_title} | Contact") }
  end

end
