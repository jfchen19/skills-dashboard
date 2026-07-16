# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/skill"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/MatchWithSimpleRegex
# Spec content is verbatim per task brief; each example groups related expectations
# for one from_dir scenario (valid / broken YAML / missing frontmatter) intentionally.
RSpec.describe Skill do
  describe ".from_dir" do
    it "parses frontmatter and stats from a valid skill dir" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "gcm"), source: "own")

      expect(skill.name).to eq("gcm")
      expect(skill.source).to eq("own")
      expect(skill.description).to match(/conventional commit/)
      expect(skill.size_bytes).to be > 0
      expect(skill.extra_files_count).to eq(1)
      expect(skill.updated_at).to be_a(Time)
      expect(skill).to be_valid
    end

    it "flags broken YAML without raising" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "broken"), source: "own")

      expect(skill).not_to be_valid
      expect(skill.error).to match(/yaml/i)
      expect(skill.name).to eq("broken") # falls back to dir name
    end

    it "flags missing frontmatter without raising" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "no-front"), source: "own")

      expect(skill).not_to be_valid
      expect(skill.error).to match(/frontmatter/i)
    end

    it "flags a directory without SKILL.md without raising" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "does-not-exist"), source: "own")

      expect(skill).not_to be_valid
      expect(skill.error).to match(/unreadable/i)
      expect(skill.name).to eq("does-not-exist") # falls back to dir name
    end

    it "flags missing required frontmatter fields" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "no-desc"), source: "own")

      expect(skill).not_to be_valid
      expect(skill.error).to match(/missing required frontmatter field/i)
      expect(skill.error).to include("description")
    end

    it "flags YAML aliases without raising" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "alias-yaml"), source: "own")

      expect(skill).not_to be_valid
      expect(skill.error).to match(/invalid yaml/i)
    end
  end

  describe "#body" do
    it "returns markdown content without frontmatter" do
      skill = described_class.from_dir(File.join(FIXTURES, "own_skills", "gcm"), source: "own")

      expect(skill.body).to start_with("# Generate Commit Message")
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/MatchWithSimpleRegex
