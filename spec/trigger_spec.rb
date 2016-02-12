require_relative '../lib/trigger'
require_relative 'helpers/logic_helpers'
require_relative 'helpers/math_helpers'

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

    it "is true for never condition" do
      switch = Switch.new
      trigger = Trigger.new(conditions: [switch.set?, never], actions: [display("foo")])

      expect(trigger.superfluous?).to eq(true)
    end

    xit "true when only clears then sets same switch" do
      switch = Switch.new
      trigger = Trigger.new(conditions: [switch.set?], actions: [switch.clear, switch.set])

      expect(trigger.superfluous?).to eq(true)
    end
  end

  xdescribe "condition logic" do
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

    it "double nesting" do
      a = TestSwitch.new
      b = TestSwitch.new
      c = TestSwitch.new

      trigger =
      _if( a )[
        _if( b )[
          _if( c ) [
            success
          ]
        ]
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq( a && b && c)
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

    it "a & !b" do
      a, b = TestSwitch.new, TestSwitch.new

      trigger =
      _if( a & !b )[
        success
      ]

      each_perm(trigger, [a, b]) do |success, a, b|
        expect(success).to eq( a && !b ), "Got #{success}, expected #{!success}: a:#{a} b:#{b}"
      end
    end

    it "a & b & !c" do
      a, b, c = TestSwitch.new, TestSwitch.new, TestSwitch.new

      trigger =
      _if( a & b & !c )[
        success
      ]

      each_perm(trigger, [a, b, c]) do |success, a, b, c|
        expect(success).to eq( a && b && !c ), "Got #{success}, expected #{!success}: a:#{a} b:#{b} c:#{c}"
      end
    end

    it "a | !b" do
      a, b = TestSwitch.new, TestSwitch.new

      trigger =
      _if( a | !b )[
        success
      ]

      each_perm(trigger, [a, b]) do |success, a, b|
        expect(success).to eq( a || !b ), "Got #{success}, expected #{!success}: a:#{a} b:#{b}"
      end
    end

    it "!a | !b" do
      a, b = TestSwitch.new, TestSwitch.new

      trigger =
      _if( !a | !b )[
        success
      ]

      each_perm(trigger, [a, b]) do |success, a, b|
        expect(success).to eq( !a || !b ), "Got #{success}, expected #{!success}: a:#{a} b:#{b}"
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

  xdescribe "Math" do
    it "x << C" do
      a = TestCounter.new(min: 0, max: 10, range: [1, 2, 3])
      b = TestCounter.new(min: 0, max: 10, range: [1, 2, 3])

      trigger = _if()[
        a << 2,
        b << 4,
      ]

      each_value(trigger, [a, b]) do |a, b|
        expect(a).to eq(2)
        expect(b).to eq(4)
      end
    end

    it "x << x" do
      a = TestCounter.new(min: 0, max: 10, range: [0, 1, 2, 3])

      trigger = _if()[
        a << a,
      ]

      each_value(trigger, [a]) do |a, a0|
        expect(a).to eq(a0)
      end
    end

    it "x << -x" do
      a = TestCounter.new(min: 0, max: 10, range: [0, 1, 2, 3])

      trigger = _if()[
        a << -a,
      ]

      each_value(trigger, [a]) do |a, a0|
        expect(a).to eq(-a0)
      end
    end

    it "x << x + C" do
      a = TestCounter.new(min: 0, max: 15, range: [1, 2, 3])

      trigger = _if()[
        a << a - 1,
      ]

      each_value(trigger, [a]) do |a, a0|
        expect(a).to eq(a0 - 1)
      end

      trigger = _if()[
        a << 10,
        a << a + 5,
      ]

      each_value(trigger, [a]) do |a|
        expect(a).to eq(15)
      end
    end

    it "x << y" do
      a = TestCounter.new(min: 0, max: 3, range: [2])
      b = TestCounter.new(min: 0, max: 10, range: [1, 5, 10])

      trigger = _if()[
        a << b,
      ]

      each_value(trigger, [a, b]) do |a, b|
        expect(a).to eq(b)
      end
    end

    it "x << y + C" do
      a = TestCounter.new(min: 0, max: 3, range: [0, 1, 2])
      b = TestCounter.new(min: 0, max: 10, range: [4, 5, 6])

      trigger = _if()[
        a << b + 2,
      ]

      each_value(trigger, [a, b]) do |a, b|
        expect(a).to eq(b + 2)
      end
    end

    it "x << 2 * y" do
      a = TestCounter.new(min: 0, max: 3, range: [0, 1, 2])
      b = TestCounter.new(min: 0, max: 10, range: [4, 5, 6])

      trigger = _if()[
        a << 2 * b,
      ]

      each_value(trigger, [a, b]) do |a, b|
        expect(a).to eq(2 * b)
      end
    end

    it "x << 3 * y + 10" do
      a = TestCounter.new(min: 0, max: 3, range: [0, 1, 2])
      b = TestCounter.new(min: 0, max: 10, range: [4, 5, 6])

      trigger = _if()[
        a << 3 * b + 10,
      ]

      each_value(trigger, [a, b]) do |a, b|
        expect(a).to eq(3 * b + 10)
      end
    end

    it "x << 50 - 5 * y" do
      x = TestCounter.new(min: 0, max: 7, range: [0, 1, 2, 3, 4])
      y = TestCounter.new(min: 0, max: 7, range: [0, 1, 2, 3, 4])

      trigger = _if()[
        x << 50 - 5 * y,
      ]

      each_value(trigger, [x, y]) do |x, y|
        expect(x).to eq(50 - 5 * y)
      end
    end

    it "x << -50 * (1 - y) + y" do
      x = TestCounter.new(min: 0, max: 7, range: [0, 1, 2, 3, 4])
      y = TestCounter.new(min: 0, max: 7, range: [0, 1, 2, 3, 4])

      trigger = _if()[
        x << -50 * (1 - y) + y,
      ]

      each_value(trigger, [x, y]) do |x, y|
        expect(x).to eq(-50 * (1 - y) + y)
      end
    end

    xit "x << y * z" do
      x = TestCounter.new(min: 0, max: 3, range: [1])
      y = TestCounter.new(min: 0, max: 10, range: [1, 2, 3, 4, 5])
      z = TestCounter.new(min: 0, max: 10, range: [1, 2, 3, 4, 5])

      trigger = _if()[
        x << y * z,
      ]

      each_value(trigger, [x, y, z]) do |x, y, z|
        expect(x).to eq(y * z)
      end
    end

    xit "x < 5" do
      x = TestCounter.new(min: 0, max: 7, range: (0..7))

      trigger =
      _if( x < 5 )[
        x << 100,
      ]

      each_value(trigger, [x]) do |x, x0|
        expect(x0 < 5).to eq(x == 100), "Expected #{x0 < 5}, got: #{x == 100}. x: #{x}, x0: #{x0}."
      end
    end

    xit "x < y + 5" do
      x = TestCounter.new(min: 0, max: 7, range: [1, 2, 3, 4])
      y = TestCounter.new(min: 0, max: 7, range: [1, 2, 3, 4])

      trigger =
      _if( x < y + 5 )[
        x << 100,
      ]

      each_value(trigger, [x, y]) do |x, y, x0, y0|
        expect(x0 < y0 + 5).to eq(x == 100)
      end
    end
  end

end
