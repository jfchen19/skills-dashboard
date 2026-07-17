# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
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

  describe "#plugin_links" do
    subject(:links) { scanner.plugin_links }

    it "maps a plugin to its repository url" do
      expect(links["superpowers"]).to eq("https://github.com/obra/superpowers")
    end

    it "reads the json from the latest version dir only" do
      expect(links.values.join).not_to include("OLD-MUST-NOT-APPEAR")
    end

    it "omits plugins without a plugin.json" do
      expect(links).not_to have_key("context7")
    end

    # rubocop:disable RSpec/ExampleLength -- one behavior: each malformed shape
    # (bad json / non-http scheme / unusable types) degrades to "no link".
    it "silently skips malformed or unusable metadata" do
      Dir.mktmpdir do |tmpdir|
        {
          "badjson" => "{ not json",
          "evil" => '{"repository": "javascript:alert(1)"}',
          "weird" => '{"repository": 42, "homepage": ["x"]}'
        }.each do |plugin, body|
          meta = File.join(tmpdir, "market-x", plugin, "1.0.0", ".claude-plugin")
          FileUtils.mkdir_p(meta)
          File.write(File.join(meta, "plugin.json"), body)
        end
        bad = described_class.new(own_dir: "/nonexistent", plugins_dir: tmpdir)

        expect(bad.plugin_links).to eq({})
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength -- one behavior: fallback when repository absent
    it "falls back to homepage when repository is absent" do
      Dir.mktmpdir do |tmpdir|
        meta = File.join(tmpdir, "market-x", "warp", "2.0.0", ".claude-plugin")
        FileUtils.mkdir_p(meta)
        File.write(File.join(meta, "plugin.json"),
                   '{"homepage": "https://github.com/warpdotdev/claude-code-warp"}')
        solo = described_class.new(own_dir: "/nonexistent", plugins_dir: tmpdir)

        expect(solo.plugin_links["warp"]).to eq("https://github.com/warpdotdev/claude-code-warp")
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength -- one behavior: npm-style repository objects
    it "accepts npm-style repository objects" do
      Dir.mktmpdir do |tmpdir|
        meta = File.join(tmpdir, "market-x", "npmish", "1.0.0", ".claude-plugin")
        FileUtils.mkdir_p(meta)
        File.write(File.join(meta, "plugin.json"),
                   '{"repository": {"type": "git", "url": "https://github.com/x/y"}}')
        solo = described_class.new(own_dir: "/nonexistent", plugins_dir: tmpdir)

        expect(solo.plugin_links["npmish"]).to eq("https://github.com/x/y")
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
