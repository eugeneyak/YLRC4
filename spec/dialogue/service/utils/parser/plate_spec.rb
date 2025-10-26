RSpec.describe Utils::Parser::Plate do
  subject { described_class.new(value).call }

  context "with valid plate format" do
    let(:value) { "А 123 БВ 45" }

    it "returns formatted plate string" do
      expect(subject).to eq("А123БВ 45")
    end
  end

  context "with valid plate format without spaces" do
    let(:value) { "А123БВ45" }

    it "returns formatted plate string" do
      expect(subject).to eq("А123БВ 45")
    end
  end

  context "with valid plate format with 3-digit region" do
    let(:value) { "А 123 БВ 123" }

    it "returns formatted plate string" do
      expect(subject).to eq("А123БВ 123")
    end
  end

  context "with invalid plate format" do
    let(:value) { "12345" }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "with lowercase input" do
    let(:value) { "а 123 бв 45" }

    it "converts to uppercase and returns formatted plate string" do
      expect(subject).to eq("А123БВ 45")
    end
  end
end
