require "test/unit"

class RequestUriFormattedTest < Test::Unit::TestCase
  def format_request_uri(request_uri)
    request_uri.gsub(%r{(?<=/)[0-9]+(?=(/|$|\.))}, ":id")
  end

  def test_ends_with_id
    assert { format_request_uri("/users/123") == "/users/:id" }
  end

  def test_contains_id
    assert { format_request_uri("/users/123/followers") == "/users/:id/followers" }
  end

  def test_id_with_ext
    assert { format_request_uri("/img/123.png") == "/img/:id.png" }
  end
end
