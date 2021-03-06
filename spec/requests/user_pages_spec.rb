require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "index page" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
      
      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link("delete") }

      describe "as am admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link("delete", href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link("delete", match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }
    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment following user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement following user count" do
          expect do
           click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

       it "should decrement followers count" do
         expect do
           click_button "Unfollow"
         end.to change(other_user.followers, :count).by(-1)
       end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end

  end

  describe "following/followers stats in profile page" do
    let(:follower) { FactoryGirl.create(:user) }
    let(:followed) { FactoryGirl.create(:user) }
    before { follower.follow!(followed) }

    describe "followed user page stats" do
      before do
        sign_in followed
        visit followers_user_path(followed)
      end
      it { should have_title(full_title("Followers")) }
      it { should have_content("1 followers") }
      it { should have_content("0 following") }
    end

    describe "follower user page stats" do
      before do
        sign_in follower
        visit following_user_path(follower)
      end
      it { should have_title(full_title("Following")) }
      it { should have_content("0 followers") }
      it { should have_content("1 following") }
    end
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

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link("change", href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content("error") }
    end

    describe "with valid information" do
      let(:new_name) { "Kota Ishimoto" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with:user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      #it { should have_link('Sign out', href: signout_path) }
      
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin:true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) } 
    let(:other_user) { FactoryGirl.create(:user) } 
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title("Following")) }
      it { should have_selector("h3", text:"Following") }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title("Followers")) }
      it { should have_selector("h3", text:"Followers") }
      it { should have_link(user.name) }
    end
  end


                      
end
