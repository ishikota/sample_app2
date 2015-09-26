require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }
    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup" do
    before { visit signup_path }
    it { should have_content("Sign up") }
    it { should have_title(full_title("Sign up")) }
    
    describe "with no-data" do
      it "should not create a user" do
       expect { click_button "Create my account" }.not_to change(User, :count)
      end
    end

    describe "with valid data" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button "Create my account" }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button "Create my account" }
        let(:user) { User.find_by(email:"user@example.com") }

        it { should have_link("Sign out") }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: "Welcome") }
      end
    end
  end
  
  describe "Error messages" do
    let(:invalid_user) { FactoryGirl.create(:user) }
    before do
      visit signup_path
      invalid_user.email = ""
      invalid_user.password = "aiueo"
      invalid_user.password_confirmation = "nanin"
    end
    
    describe "Signup with invalid information" do
      before do
        fill_in "Name", with: invalid_user.name
        fill_in "Email", with: invalid_user.email
        fill_in "Password", with: invalid_user.password
        fill_in "Confirmation", with: invalid_user.password_confirmation
        click_button "Create my account"
      end

      it { should have_content("error") }
      
      it "should display error messages" do
        invalid_user.errors.full_messages.each do |msg|
          it { should have_content(msg) }
        end
      end
    end

    describe "signup with valid information" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
        click_button "Create my account"
      end
      it { should_not have_content("error") }
      it { should have_title("Example User") }
      it { should have_selector('div.alert.alert-success', text: 'Welcome') }
    end
  end

end
