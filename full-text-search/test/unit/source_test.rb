require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  test "find by name" do
    assert_equal(sources(:wikipedia_ja).url,
                 Source.find_by_name("Wikipedia (ja)").url)
  end
end
