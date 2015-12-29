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

    it "handles :true, :false, :set, :clear, :toggle" do
      expect(format_switch_mod(:true)).to eq("set")
      expect(format_switch_mod(:set)).to eq("set")
      expect(format_switch_mod(:false)).to eq("clear")
      expect(format_switch_mod(:clear)).to eq("clear")
      expect(format_switch_mod(:toggle)).to eq("toggle")
    end

    it "allows properly formatted to pass" do
      expect(format_switch_mod("set")).to eq("set")
      expect(format_switch_mod("clear")).to eq("clear")
      expect(format_switch_mod("toggle")).to eq("toggle")
    end
  end

end
