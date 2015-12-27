require_relative '../lib/switch'

describe Switch do

  before do
    @store = Store.new(size: 256)
  end

  describe "#initialize" do
    it "allocates an unused id" do
      first = Switch.new(store: @store)
      second = Switch.new(store: @store)

      expect(first.id).to eq(0)
      expect(second.id).to eq(1)
    end
  end

  describe "#destroy" do
    it "deallocates the id" do
      first = Switch.new(store: @store)
      second = Switch.new(store: @store)
      first.destroy
      third = Switch.new(store: @store)

      expect(second.id).to eq(1)
      expect(third.id).to eq(0)
    end

    it "sets its id to nil" do
      switch = Switch.new(store: @store)
      switch.destroy
      expect(switch.id).to eq(nil)
    end
  end

  describe "#clone" do
    it "creates a new object" do
      switch = Switch.new(store: @store)
      clone = switch.clone
      expect(switch.object_id).to_not eq(clone.object_id)
    end

    it "has same attribute values" do
      switch = Switch.new(store: @store, inverted: true, id: 27)
      clone = switch.clone
      
      switch.instance_variables.each do |variable|
        original_var = switch.instance_variable_get(variable)
        clone_var = clone.instance_variable_get(variable)
        expect(original_var).to eq(clone_var)
      end
    end

    it "can specify different values" do
      switch = Switch.new(store: @store, inverted: true, id: 30)
      clone = switch.clone(inverted: false)

      expect(clone.inverted).to eq(false)
      expect(clone.id).to eq(switch.id)
      expect(clone.store).to eq(switch.store)
    end
  end
end
