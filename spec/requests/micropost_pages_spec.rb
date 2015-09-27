require 'spec_helper'

describe "MicropostPages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }
    describe "with invalid information" do
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error message" do
        before { click_button "Post" }
        it { should have_content("error") }
      end
    end

    describe "with valid information" do
      before { fill_in "micropost_content", with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }
      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "micropost count" do
    before do
      user.microposts.create(content: "aaa")
    end

    describe "a micropost" do
      before { visit root_path }
      specify { expect(page).to have_content("1 micropost") }
    end

    describe "multi microposts" do
      before do
        user.microposts.create(content: "bbb")
        visit root_path
      end
      specify { expect(page).to have_content("2 microposts") }
    end
  end

  describe "pagenation" do
    before do
     31.times do |i|
       user.microposts.create(content: "#{i}aaa")
     end
     visit root_path
    end
    it { should have_content("1aaa") }
    it { should_not have_content("31aaa") }
  end

=begin exercise 4
  describe "feed delete not displayed" do
    let(:other_user) { FactoryGirl.create(:user) }
    let(:post) { other_user.microposts.build(content: "hoge") }

    before do
      user.feed.append(post)
      visit root_path
    end

    it { should have_title("Sample App") }
    it { should have_content("hoge") }
    it { should_not have_content("delete") }
  end
=end



end
