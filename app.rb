# frozen_string_literal: true

require "sinatra/base"
require "kramdown"
require_relative "lib/skill_scanner"
require_relative "lib/zh_dict"

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

    def zh_dict
      ZhDict.load(ENV.fetch("ZH_FILE", File.expand_path("data/zh.yml", __dir__)))
    end
  end

  get "/" do
    @skills = scanner.scan
    @sources = @skills.map(&:source).uniq.sort
    @stats = {
      total: @skills.size,
      sources: @sources.size,
      broken: @skills.count { |s| !s.valid? },
      extra_files: @skills.sum(&:extra_files_count)
    }
    @zh = zh_dict
    erb :index
  end

  get "/skills/:source/:name" do
    @skill = scanner.scan.find { |s| s.source == params[:source] && s.name == params[:name] }
    halt 404, "skill not found" unless @skill

    @html = Kramdown::Document.new(@skill.body).to_html
    @zh_note = zh_dict.for(params[:source], params[:name])
    erb :show, layout: params[:embed] != "1"
  end
end
