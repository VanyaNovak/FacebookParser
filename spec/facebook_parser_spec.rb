require "spec_helper"
require "./facebook_parser"
require 'faker'

describe FacebookParser do
  describe "#contacts_list" do
    subject { FacebookParser.new("email", "somepass").contacts_list }

    context "when credentials invalid" do
      it "returns not authorized" do
        expect(subject).to eq "authorization failed"
      end
    end

    context "when authorized" do
      let(:collected_names) do
        10.times.map do
          Faker::Name.name
        end
      end

      let(:file_path) { "data.csv" }
      let(:csv) do
        CSV.open(file_path)
      end

      before do
        allow_any_instance_of(FacebookParser).to receive(:auth).and_return(true)
        allow_any_instance_of(FacebookParser).to receive(:collect_names).and_return(collected_names)
      end

      after do
        File.delete(file_path)
      end

      it "generates csv file" do
        subject

        expect(csv.to_a.flatten).to match_array(
          collected_names.each do |name|
            name
          end
        )
      end

    end
  end
end