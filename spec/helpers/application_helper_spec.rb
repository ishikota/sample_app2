require 'spec_helper'

describe ApplicationHelper do
  
  describe "full_title" do
    it "should return full title with foo" do
      expect(full_title("foo")).to eq("Ruby on Rails Tutorial Sample App | foo")
    end

    it "should not display this separator '|' " do
      expect(full_title("")).not_to match(/\|/)
    end

  end

end
