require_relative '../lib/counters/dc'

describe DC do
  before do
    @store = Store.new(size: 256)
  end

  describe "#initialize" do
    it "allocates an unused id" do
      first = DC.new(store: @store)
      second = DC.new(store: @store)

      expect(first.id).to eq(0)
      expect(second.id).to eq(1)
    end
  end
end
