require "spec_helper"
describe "api/v1/meta_data", :type => :api do
  let(:url) { "http://api.hungrlr.awesome/v1/meta_data.json" }
  it "posts metadata" do
    post url, url: "http://google.com"
    JSON.parse(last_response.body)["title"].should == "Google"
  end

end
