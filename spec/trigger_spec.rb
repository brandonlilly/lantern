require_relative '../lib/trigger'

describe Trigger do

  before do

  end

  describe "#initialize" do
    it "is preserved by default" do
      trigger = Trigger.new
      expect(trigger.preserved).to eq(true)
    end
  end

  describe "#superfluous?" do
    it "false for a normal trigger" do
      switch = Switch.new
      trigger = Trigger.new(
        conditions: [ switch.set? ],
        actions: [ display("trigger active") ]
      )

      expect(trigger.superfluous?).to be(false)
    end

    it "is true if no actions" do
      trigger = Trigger.new(conditions: [], actions: [])

      expect(trigger.superfluous?).to eq(true)
    end

    it "true when only clears then sets same switch" do
      switch = Switch.new
      trigger = Trigger.new(conditions: [switch.set?], actions: [switch.clear, switch.set])

      expect(trigger.superfluous?).to eq(true)
    end
  end
end
