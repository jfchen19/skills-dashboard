# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../lib/zh_dict"

RSpec.describe ZhDict do
  subject(:dict) { described_class.load(File.join(FIXTURES, "zh.yml")) }

  it "returns the translation for a known source/name" do
    expect(dict.for("own", "gcm")).to eq("讀 git diff 產生單行 Conventional Commits 訊息。")
  end

  it "returns nil for an unknown skill" do
    expect(dict.for("own", "nope")).to be_nil
  end

  it "returns nil for an unknown source" do
    expect(dict.for("ghost", "gcm")).to be_nil
  end

  it "returns nil for a blank translation" do
    expect(dict.for("own", "blank-zh")).to be_nil
  end

  it "degrades to an empty dict when the file is missing" do
    expect(described_class.load("/nonexistent/zh.yml").for("own", "gcm")).to be_nil
  end

  it "degrades to an empty dict when the YAML is malformed" do
    Dir.mktmpdir do |tmpdir|
      path = File.join(tmpdir, "zh.yml")
      File.write(path, "own: [broken")

      expect(described_class.load(path).for("own", "gcm")).to be_nil
    end
  end

  it "degrades to an empty dict when the top level is not a hash" do
    Dir.mktmpdir do |tmpdir|
      path = File.join(tmpdir, "zh.yml")
      File.write(path, "- just\n- a\n- list\n")

      expect(described_class.load(path).for("own", "gcm")).to be_nil
    end
  end

  it "returns nil when a source entry is a scalar instead of a hash" do
    Dir.mktmpdir do |tmpdir|
      path = File.join(tmpdir, "zh.yml")
      File.write(path, "own: oops\n")

      expect(described_class.load(path).for("own", "gcm")).to be_nil
    end
  end
end
