require "spec_helper"
require "./facebook_parser"

describe FacebookParser do
  describe "#contacts_list" do
    subject { FacebookParser.new("email", "somepass").contacts_list }

    context "when credentials invalid" do
      it "returns not authorized" do
        expect(subject).to eq "authorization failed"
      end
    end
  end
end