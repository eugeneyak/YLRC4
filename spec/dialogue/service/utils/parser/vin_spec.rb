
RSpec.describe Dialogue::Service::Utils::Parser::VIN do
  subject { described_class.new(value).call }

  context "with valid 17-character VIN" do
    let(:value) { "1HGCM82633A004352" }

    it "returns the value" do
      expect(subject).to eq("1HGCM82633A004352")
    end
  end

  context "with lowercase valid VIN" do
    let(:value) { "1hgcm82633a004352" }

    it "converts to uppercase and returns the value" do
      expect(subject).to eq("1HGCM82633A004352")
    end
  end

  context "with invalid VIN length" do
    let(:value) { "1HGCM82633A00435" }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "with invalid characters" do
    let(:value) { "1HGCM82633A00435@" }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "with empty string" do
    let(:value) { "" }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end
end
