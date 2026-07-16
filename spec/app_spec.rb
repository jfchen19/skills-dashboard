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

    it "renders one card per skill with data attributes" do
      get "/"

      expect(last_response.body).to include('data-name="gcm"')
        .and include('data-source="superpowers"')
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
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
