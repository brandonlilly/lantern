require_relative '../lib/dc'

describe DC do

  before do
    @store = Store.new(size: 256)
  end

  describe "#initialize" do
    it "allocates an unused id" do
      first = DC.temp(store: @store)
      second = DC.temp(store: @store)

      expect(first.id).to eq(0)
      expect(second.id).to eq(1)
    end
  end

  describe "#destroy" do
    it "deallocates the id" do
      first = DC.temp(store: @store)
      second = DC.temp(store: @store)
      first.destroy
      third = DC.temp(store: @store)

      expect(second.id).to eq(1)
      expect(third.id).to eq(0)
    end

    it "sets its id to nil" do
      dc = DC.temp(store: @store)
      dc.destroy
      expect(dc.id).to eq(nil)
    end
  end
end
