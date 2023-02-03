require "spec_helper"
require "./facebook_parser"

describe FacebookParser do
  describe "#contacts_list" do
    subject { FacebookParser.new("email", "somepass") }

    context "when credentials invalid" do
      it "returns not authorized" do
        parser = subject

        expect(parser.contacts_list).to eq nil
        expect(parser.session.current_url).to include FacebookParser::FACEBOOK_URI
        expect(parser.authorized).to eq false
      end
    end

    context "when authorized" do
      let(:collected_names) do
        [
          "Ivan Novak",
          "John Doe",
          "Mike Peterson"
        ]
      end

      before do
        allow_any_instance_of(FacebookParser).to receive(:auth).and_return(true)
        allow_any_instance_of(FacebookParser).to receive(:collect_names).and_return(collected_names)
      end

      it "returns correct data" do
        parser = subject

        parser.contacts_list

        expect(parser.authorized).to eq true
        expect(File.exist?('data.csv')).to eq true
        expect(CSV.open("data.csv", "r").to_a.flatten).to eq collected_names
      end

      context "when contacts does not exists" do
        let(:collected_names) { nil }

        it "returns nil" do
          expect(subject.contacts_list).to eq nil
        end
      end
    end
  end
end