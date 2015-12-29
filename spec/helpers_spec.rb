require_relative "../lib/helpers"
require_relative "../lib/data"

describe "Helpers" do

  describe "format_player" do
    it "doesn't alter properly formatted players" do
      Data::PLAYER_TYPES.each do |player|
        expect(format_player(player)).to eq(player)
      end
    end

    it "handles P# string" do
      expect(format_player("P1")).to eq("Player 1")
      expect(format_player("P12")).to eq("Player 12")
    end

    it "handles P# symbol" do
      expect(format_player(:P1)).to eq("Player 1")
      expect(format_player(:P10)).to eq("Player 10")
    end

    xit "handles lowercase inputs" do
      expect(format_player("player 2")).to eq("Player 2")
      expect(format_player("player 11")).to eq("Player 11")
      expect(format_player(:p3)).to eq("Player 3")
    end

    xit "handles irregular players" do
      expect(format_player("All Players")).to eq("All players")
      # more
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
