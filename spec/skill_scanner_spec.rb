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

  describe "#scan (plugin skills)" do
    it "labels plugin skills with the plugin directory name as source" do
      sources = scanner.scan.map(&:source).uniq

      expect(sources).to include("superpowers", "context7")
    end

    # rubocop:disable RSpec/MultipleExpectations -- per task brief verbatim: both
    # expectations verify one behavior (dedupe to a single, correct-version skill).
    it "takes only the latest version of a plugin" do
      brainstorming = scanner.scan.select { |s| s.name == "brainstorming" }

      expect(brainstorming.size).to eq(1)
      expect(brainstorming.first.description).to include("v6.1.1")
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "uses the only version even when not semver (e.g. unknown)" do
      expect(scanner.scan.map(&:name)).to include("query-docs")
    end

    it "sorts by source then name" do
      result = scanner.scan

      expect(result).to eq(result.sort_by { |s| [s.source, s.name] })
    end
  end
end
