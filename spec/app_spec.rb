# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require "tmpdir"

ENV["SKILLS_DIR"] = File.join(FIXTURES, "own_skills")
ENV["PLUGINS_DIR"] = File.join(FIXTURES, "plugins_cache")
require_relative "../app"

# rubocop:disable RSpec/SpecFilePathFormat -- per task brief verbatim: file is
# named spec/app_spec.rb (mirrors app.rb), not skills_dashboard_spec.rb.
RSpec.describe SkillsDashboard do
  include Rack::Test::Methods

  def app = described_class

  describe "GET /" do
    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations -- per task
    # brief verbatim: both expectations verify one behavior (the stats section
    # renders all four tiles).
    it "renders stat tiles" do
      get "/"

      expect(last_response).to be_ok
      expect(last_response.body).to include("技能總數")
        .and include("來源數")
        .and include("平均 SKILL.md 大小")
        .and include("附加參考文件")
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations

    it "renders one table row per skill with data attributes" do
      get "/"

      expect(last_response.body).to include('data-name="gcm"')
        .and include('data-source="superpowers"')
    end

    it "renders the source tree and skill table containers" do
      get "/"

      expect(last_response.body).to include('id="source-tree"')
        .and include('id="skill-table"')
    end

    it "renders exactly one tr.row per skill" do
      get "/"

      expect(last_response.body.scan('class="row"').size).to eq(8)
    end

    # rubocop:disable RSpec/MultipleExpectations -- per task brief verbatim: both
    # expectations verify one behavior (broken skill renders instead of 500ing).
    it "marks broken skills instead of crashing" do
      get "/"

      expect(last_response).to be_ok
      expect(last_response.body).to include("data-name=\"broken\"")
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations -- one
    # behavior (auto-escaping of skill-controlled text) asserted positively
    # (entities present) and negatively (raw payload absent).
    it "escapes skill-controlled text so frontmatter cannot inject HTML" do
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p(File.join(tmpdir, "evil"))
        File.write(File.join(tmpdir, "evil", "SKILL.md"), <<~MD)
          ---
          name: evil
          description: '<script>alert(1)</script>"onmouseover="x'
          ---
          body
        MD
        original = ENV.fetch("SKILLS_DIR", nil)
        ENV["SKILLS_DIR"] = tmpdir

        get "/"

        expect(last_response.body).to include("&lt;script&gt;")
        expect(last_response.body).not_to include("<script>alert(1)</script>")
      ensure
        ENV["SKILLS_DIR"] = original
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations

    it "exposes hooks for client-side filtering" do
      get "/"

      expect(last_response.body).to include('id="search"')
        .and include('id="source-tree"')
        .and include("data-text=")
    end

    it "includes the skill detail modal markup" do
      get "/"

      expect(last_response.body).to include('id="skill-modal"')
    end
  end

  describe "GET /skills/:source/:name" do
    # rubocop:disable RSpec/MultipleExpectations -- per task brief verbatim: both
    # expectations verify one behavior (kramdown-rendered markdown, real HTML).
    it "renders the full SKILL.md as HTML" do
      get "/skills/own/gcm"

      expect(last_response).to be_ok
      expect(last_response.body).to include("<h1")
        .and include("Generate Commit Message")
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "returns 404 for unknown skill" do
      get "/skills/own/nope"

      expect(last_response.status).to eq(404)
    end

    it "renders without layout when embed=1" do
      get "/skills/own/gcm", embed: "1"

      expect(last_response.body).not_to include("<!DOCTYPE html>")
    end

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations -- one
    # behavior (skill-controlled name is escaped while the kramdown body still
    # renders as real HTML) asserted with both positive and negative expectations.
    it "escapes the skill name while rendering the markdown body as raw HTML" do
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p(File.join(tmpdir, "evil"))
        File.write(File.join(tmpdir, "evil", "SKILL.md"), <<~MD)
          ---
          name: '<b>evil'
          description: evil skill
          ---
          # Evil Body
        MD
        original = ENV.fetch("SKILLS_DIR", nil)
        ENV["SKILLS_DIR"] = tmpdir

        # NOTE: the malicious name has no closing tag / literal "/" — a raw "/"
        # (even percent-encoded as %2F) gets decoded into an extra path segment
        # before Sinatra's single-segment :name route matches, which would 404.
        get "/skills/own/#{Rack::Utils.escape('<b>evil')}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("&lt;b&gt;evil")
        expect(last_response.body).not_to include("<b>evil")
        expect(last_response.body).to include("<h1")
      ensure
        ENV["SKILLS_DIR"] = original
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
