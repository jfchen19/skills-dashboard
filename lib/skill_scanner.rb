# frozen_string_literal: true

require_relative "skill"

class SkillScanner
  OWN_SOURCE = "own"

  def initialize(own_dir:, plugins_dir:)
    @own_dir = own_dir
    @plugins_dir = plugins_dir
  end

  def scan
    own_skills.sort_by { |s| [s.source, s.name] }
  end

  private

  def own_skills
    skill_dirs(@own_dir).map { |dir| Skill.from_dir(dir, source: OWN_SOURCE) }
  end

  def skill_dirs(base)
    Dir.glob(File.join(base, "*", "SKILL.md")).map { |f| File.dirname(f) }
  end
end
