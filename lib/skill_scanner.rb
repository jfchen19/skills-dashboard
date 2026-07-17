# frozen_string_literal: true

require_relative "skill"
require "json"

class SkillScanner
  OWN_SOURCE = "own"

  def initialize(own_dir:, plugins_dir:, marketplaces_dir: nil)
    @own_dir = own_dir
    @plugins_dir = plugins_dir
    @marketplaces_dir = marketplaces_dir
  end

  def scan
    (own_skills + plugin_skills).sort_by { |s| [s.source, s.name] }
  end

  def plugin_links
    market_cache = {}
    plugin_dirs.each_with_object({}) do |plugin_dir, links|
      version_dir = latest_version_dir(plugin_dir)
      next unless version_dir

      url = source_url(File.join(version_dir, ".claude-plugin", "plugin.json")) ||
            marketplace_url(plugin_dir, market_cache)
      links[File.basename(plugin_dir)] = url if url
    end
  end

  private

  def own_skills
    skill_dirs(@own_dir).map { |dir| Skill.from_dir(dir, source: OWN_SOURCE) }
  end

  def plugin_skills
    plugin_dirs.flat_map do |plugin_dir|
      version_dir = latest_version_dir(plugin_dir)
      next [] unless version_dir

      skill_dirs(File.join(version_dir, "skills")).map do |dir|
        Skill.from_dir(dir, source: File.basename(plugin_dir))
      end
    end
  end

  def plugin_dirs
    Dir.glob(File.join(@plugins_dir, "*", "*")).select { |p| File.directory?(p) }
  end

  def latest_version_dir(plugin_dir)
    versions = Dir.children(plugin_dir).select { |c| File.directory?(File.join(plugin_dir, c)) }
    return if versions.empty?

    best = versions.max_by do |v|
      Gem::Version.correct?(v) ? Gem::Version.new(v) : Gem::Version.new("0")
    end
    File.join(plugin_dir, best)
  end

  def skill_dirs(base)
    Dir.glob(File.join(base, "*", "SKILL.md")).map { |f| File.dirname(f) }
  end

  def source_url(json_path)
    meta = JSON.parse(File.read(json_path))
    return unless meta.is_a?(Hash)

    [meta["repository"], meta["homepage"]]
      .map { |v| v.is_a?(Hash) ? v["url"] : v }
      .find { |v| v.is_a?(String) && v.match?(%r{\Ahttps?://}) }
  rescue SystemCallError, JSON::ParserError
    nil
  end

  def marketplace_url(plugin_dir, cache)
    return unless @marketplaces_dir

    market = File.basename(File.dirname(plugin_dir))
    entries = cache[market] ||= marketplace_entries(market)
    entries[File.basename(plugin_dir)]
  end

  # marketplace.json is external content like plugin.json: any missing file,
  # bad JSON, or unexpected shape degrades to "no links from this marketplace".
  def marketplace_entries(market)
    path = File.join(@marketplaces_dir, market, ".claude-plugin", "marketplace.json")
    plugins = JSON.parse(File.read(path))["plugins"]
    return {} unless plugins.is_a?(Array)

    plugins.each_with_object({}) do |entry, map|
      next unless entry.is_a?(Hash)

      url = entry["homepage"]
      map[entry["name"]] = url if url.is_a?(String) && url.match?(%r{\Ahttps?://})
    end
  rescue SystemCallError, JSON::ParserError, TypeError, NoMethodError
    {}
  end
end
