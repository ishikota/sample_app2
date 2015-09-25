require 'spec_helper'

describe User do

  before { @user = User.new(name: "Example User", email:"user@example.com",
                           password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = "" }
    it { should_not be_valid } 
  end

  describe "when name is too long" do
    before { @user.name = 'a'*51 }
    it { should_not be_valid }
  end

  describe "when email address is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM Asfdsf@sdfd.fdsfd.com sf-_sd@s.fom]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end

    it "should not be valid" do
      addresses = %w[@foo.com kota.ishi@oo@oo.com k.i@.com a@co.jp.]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email address is duplicated" do
    before do
      user_with_same_address = @user.dup
      user_with_same_address.email = @user.email.upcase
      user_with_same_address.save
    end
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = "a"*5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { @user.authenticate("invalid") }
      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "email address with mix case" do
    let(:mixed_case_ad) { "IshiKota@gmail.COm" }
    it "should be saved as lower case" do
      @user.email = mixed_case_ad
      @user.save
      expect(@user.email).to eq mixed_case_ad.downcase
    end
  end


end
