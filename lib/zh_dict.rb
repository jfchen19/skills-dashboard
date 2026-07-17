# frozen_string_literal: true

require "yaml"

# Sidecar Chinese one-liners for skills (data/zh.yml), keyed source -> name.
# Read-only lookup; any load failure degrades to an empty dict so pages
# never crash on a broken or missing translation file.
class ZhDict
  def self.load(path)
    data = YAML.safe_load_file(path)
    new(data.is_a?(Hash) ? data : {})
  rescue SystemCallError, Psych::Exception
    new({})
  end

  def initialize(data)
    @data = data
  end

  def for(source, name)
    value = @data.dig(source, name)
    return nil unless value.is_a?(String)

    text = value.strip
    text.empty? ? nil : text
  end
end
