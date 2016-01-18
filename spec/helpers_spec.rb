require_relative "../lib/helpers"
require_relative "../lib/data"

describe "Helpers" do

  describe "format_player" do
    it "doesn't alter properly formatted players" do
      Data::PLAYER_TYPES.each do |player|
        expect(format_player(player)).to eq(player)
      end
    end

    it "handles 'P#', 'player #', 'player#'" do
      expect(format_player("P1")).to eq("Player 1")
      expect(format_player("P12")).to eq("Player 12")
      expect(format_player("player 9")).to eq("Player 9")
      expect(format_player("player 11")).to eq("Player 11")
      expect(format_player("player10")).to eq("Player 10")
    end

    it "handles uncommon players" do
      expect(format_player("All Players")).to eq("All players")
      expect(format_player("Neutral")).to eq("Player 12")
      expect(format_player("foes")).to eq("Foes")
      expect(format_player("allies")).to eq("Allies")
      expect(format_player("CP")).to eq("Current Player")
      expect(format_player("f1")).to eq("Force 1")
      expect(format_player("Force2")).to eq("Force 2")
      expect(format_player("force 3")).to eq("Force 3")
    end

    it "handles symbols" do
      expect(format_player(:p1)).to eq("Player 1")
      expect(format_player(:allplayers)).to eq("All players")
    end
  end

  describe "format_switch_mod" do
    it "handles booleans" do
      expect(format_switch_mod(true)).to eq("set")
      expect(format_switch_mod(false)).to eq("clear")
    end

    it "handles :true, :false, :set, :clear, :toggle, :randomize" do
      expect(format_switch_mod(:true)).to eq("set")
      expect(format_switch_mod(:set)).to eq("set")
      expect(format_switch_mod(:false)).to eq("clear")
      expect(format_switch_mod(:clear)).to eq("clear")
      expect(format_switch_mod(:clear)).to eq("clear")
      expect(format_switch_mod(:randomize)).to eq("randomize")
    end

    it "allows properly formatted to pass" do
      expect(format_switch_mod("set")).to eq("set")
      expect(format_switch_mod("clear")).to eq("clear")
      expect(format_switch_mod("toggle")).to eq("toggle")
      expect(format_switch_mod("randomize")).to eq("randomize")
    end

    it "allows for aliases" do
      expect(format_switch_mod("random")).to eq("randomize")
    end
  end

  describe "format_switch_state" do
    it "handles booleans" do
      expect(format_switch_state(true)).to eq("is set")
      expect(format_switch_state(false)).to eq("not set")
    end

    it "handles aliases" do
      expect(format_switch_state("IsSet")).to eq("is set")
      expect(format_switch_state("set")).to eq("is set")
      expect(format_switch_state(:is_set)).to eq("is set")
      expect(format_switch_state("NotSet")).to eq("not set")
      expect(format_switch_state(:not_set)).to eq("not set")
      expect(format_switch_state("clear")).to eq("not set")
    end

    it "allows properly formatted to pass" do
      expect(format_switch_state("is set")).to eq("is set")
      expect(format_switch_state("not set")).to eq("not set")
    end
  end

  describe "format_resource_type" do
    it "handles aliases" do
      expect(format_resource_type(:Ore)).to eq("ore")
      expect(format_resource_type("minerals")).to eq("ore")
      expect(format_resource_type(:gas)).to eq("gas")
      expect(format_resource_type(:vespene)).to eq("gas")
      expect(format_resource_type('Vespene Gas')).to eq("gas")
      expect(format_resource_type("oReAnDGas")).to eq("ore and gas")
      expect(format_resource_type("both")).to eq("ore and gas")
    end

    it "allows properly formatted to pass" do
      expect(format_resource_type("ore")).to eq("ore")
      expect(format_resource_type("gas")).to eq("gas")
      expect(format_resource_type("ore and gas")).to eq("ore and gas")
    end
  end

end
