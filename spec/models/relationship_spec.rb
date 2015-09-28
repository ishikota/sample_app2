require 'spec_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower_id) }
    it { should respond_to(:followed_id) }
    its(:follower) { should eq follower }
    its(:followed) { should eq followed }
  end

  describe "when follwer id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end

=begin
  it "should destroy associated relationships" do
    relationships = follower.relationships.to_a
    follower.destroy
    expect(relationships).not_to be_empty
    relationships.each do |r|
      expect(Relationship.where(followed_id: r.id)).to be_empty
    end
  end
=end
end
