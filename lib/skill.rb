# frozen_string_literal: true

require "yaml"

# rubocop:disable Style/DataInheritance -- deliberate per task brief: the block form
# of Data.define scopes constants like FRONTMATTER inside the anonymous class in a
# way that traps class-method self-references; inheriting from Data.define(...)
# avoids that.
class Skill < Data.define(:name, :source, :description, :path, :size_bytes,
                          :extra_files_count, :updated_at, :error)
  # rubocop:enable Style/DataInheritance
  FRONTMATTER = /\A---\s*\n(.*?)\n---\s*\n?/m

  # rubocop:disable Metrics/MethodLength -- verbatim per task brief: each Data.define
  # field is assigned explicitly and kept in one place for readability.
  def self.from_dir(dir, source:)
    skill_md = File.join(dir, "SKILL.md")
    raw = File.read(skill_md)
    front, error = parse_frontmatter(raw)

    new(
      name: front.fetch("name", File.basename(dir)) || File.basename(dir),
      source: source,
      description: front.fetch("description", nil),
      path: dir,
      size_bytes: File.size(skill_md),
      extra_files_count: Dir.glob(File.join(dir, "**", "*")).count do |f|
        File.file?(f) && f != skill_md
      end,
      updated_at: File.mtime(skill_md),
      error: error
    )
  end
  # rubocop:enable Metrics/MethodLength

  def self.parse_frontmatter(raw)
    match = raw.match(FRONTMATTER)
    return [{}, "missing frontmatter"] unless match

    parsed = YAML.safe_load(match[1])
    return [{}, "frontmatter is not a mapping"] unless parsed.is_a?(Hash)

    [parsed, nil]
  rescue Psych::SyntaxError => e
    [{}, "invalid YAML: #{e.message}"]
  end

  def valid? = error.nil?

  def body
    File.read(File.join(path, "SKILL.md")).sub(FRONTMATTER, "")
  end
end
