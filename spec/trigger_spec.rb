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

    it "(a | b) | !(c | d)" do
      a = TestSwitch.new
      b = TestSwitch.new
      c = TestSwitch.new
      d = TestSwitch.new

      trigger =
      _if( (a | b) | !(c | d) )[
        success
      ]

      each_perm(trigger, [a, b, c, d]) do |success, a, b, c, d|
        expect(success).to eq( (a || b) || !(c || d) )
      end
    end

    it "!!(a | b)" do
      a, b = @a, @b

      trigger =
      _if( !!(a | b) )[
        success
      ]

      each_perm(trigger, [a, b]) do |success, a, b|
        expect(success).to eq( a || b )
      end
    end

    it "custom conditional" do
      def xor(cond1, cond2)
        conditional {|cond| [
          _if(cond1)[cond.toggle],
          _if(cond2)[cond.toggle],
        ]}
      end

      a, b, c, d = TestSwitch.new, TestSwitch.new, TestSwitch.new, TestSwitch.new

      trigger =
      _if( xor(a, b) | xor(c, d) )[
        success()
      ]

      each_perm(trigger, [a, b, c, d]) do |success, a, b, c, d|
        expect(success).to eq( a ^ b || c ^ d )
      end
    end

    it "really complicated conditions" do
      a, b, c, d = TestSwitch.new, TestSwitch.new, TestSwitch.new, TestSwitch.new

      trigger =
      _if( !(a & !(c | d) | !b) )[
        _if( (c | d | b) & a )[
          display("red herring"),
          _if( !d )[
            display("another red herring"),
          ]
        ],
        _if( a & !(c & d & b) | a )[
          _if( !d | !c)[
            success
          ]
        ],
        _if( a )[
          display("red herring the third")
        ]
      ]

      each_perm(trigger, [a, b, c, d]) do |success, a, b, c, d|
        expect(success).to eq( !(a && !(c || d) || !b) && (a && !(c && d && b) || a) && (!d || !c) )
      end
    end
  end

end
