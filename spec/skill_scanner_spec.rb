# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/skill_scanner"

RSpec.describe SkillScanner do
  subject(:scanner) do
    described_class.new(
      own_dir: File.join(FIXTURES, "own_skills"),
      plugins_dir: File.join(FIXTURES, "plugins_cache")
    )
  end

  describe "#scan (own skills)" do
    it "returns one Skill per directory containing SKILL.md" do
      own = scanner.scan.select { |s| s.source == "own" }

      expect(own.map(&:name)).to contain_exactly("gcm", "broken", "no-front", "no-desc", "alias-yaml")
    end

    it "ignores loose files like README.md" do
      expect(scanner.scan.map(&:name)).not_to include("README")
    end

    it "returns empty array when own_dir does not exist" do
      empty = described_class.new(own_dir: "/nonexistent", plugins_dir: "/nonexistent")

      expect(empty.scan).to eq([])
    end
  end
end
