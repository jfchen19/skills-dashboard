# frozen_string_literal: true

require "sinatra/base"
require "kramdown"
require_relative "lib/skill_scanner"

class SkillsDashboard < Sinatra::Base
  set :views, File.join(__dir__, "views")
  set :public_folder, File.join(__dir__, "public")
  set :erb, escape_html: true

  helpers do
    def scanner
      SkillScanner.new(
        own_dir: ENV.fetch("SKILLS_DIR", File.expand_path("~/.claude/skills")),
        plugins_dir: ENV.fetch("PLUGINS_DIR", File.expand_path("~/.claude/plugins/cache"))
      )
    end

    def human_size(bytes)
      bytes < 1024 ? "#{bytes} B" : format("%.1f KB", bytes / 1024.0)
    end
  end

  get "/" do
    @skills = scanner.scan
    @sources = @skills.map(&:source).uniq.sort
    @stats = {
      total: @skills.size,
      sources: @sources.size,
      avg_size: @skills.empty? ? 0 : @skills.sum(&:size_bytes) / @skills.size,
      extra_files: @skills.sum(&:extra_files_count)
    }
    erb :index
  end

  get "/skills/:source/:name" do
    @skill = scanner.scan.find { |s| s.source == params[:source] && s.name == params[:name] }
    halt 404, "skill not found" unless @skill

    @html = Kramdown::Document.new(@skill.body).to_html
    erb :show, layout: params[:embed] != "1"
  end
end
