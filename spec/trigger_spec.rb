require_relative '../lib/trigger'
require_relative 'test_helpers'

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

  describe "condition logic" do
    before do
      @a = TestSwitch.new
      @b = TestSwitch.new
      @c = TestSwitch.new
    end

    it "a & b & c" do
      a = TestSwitch.new
      b = TestSwitch.new
      c = TestSwitch.new

      trigger =
      _if( a & b & c )[
        success(),
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq(a && b && c)
      end
    end

    it "a | b | c" do
      a = TestSwitch.new
      b = TestSwitch.new
      c = TestSwitch.new

      trigger =
      _if( a | b | c )[
        success(),
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq(a || b || c)
      end
    end

    it "a | (b & c)" do
      a, b, c = @a, @b, @c

      trigger =
      _if( a | (b & c) )[
        success(),
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq(a || (b && c))
      end
    end

    it "!(a & b) and !(a | b)" do
      a, b, c = @a, @b, @c

      each_perm(_if( !(a & b) )[ success ], [a, b]) do |success, a, b|
        expect(success).to eq( !(a && b) )
      end

      each_perm(_if( !(a | b) )[ success ], [a, b]) do |success, a, b|
        expect(success).to eq( !(a || b) )
      end
    end

    it "simple nesting" do
      a = TestSwitch.new
      b = TestSwitch.new

      trigger =
      _if( a )[
        _if( b )[
          success
        ]
      ]

      each_perm(trigger, [a, b]) do |success, a, b|
        expect(success).to eq( a && b )
      end
    end

    it "nested conditionals" do
      a = TestSwitch.new
      b = TestSwitch.new
      c = TestSwitch.new

      trigger =
      _if( a | b )[
        _if( b | c )[
          success
        ],
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq( (a || b) && (b || c) )
      end
    end
  end

end
