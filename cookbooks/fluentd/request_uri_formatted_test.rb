require "test/unit"

class RequestUriFormattedTest < Test::Unit::TestCase
  def format_request_uri(request_uri)
    request_uri.gsub(%r{(?<=/)[0-9]+(?=(/|$|\.))}, ":id").gsub(%r{(?<=/)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?=(/|$|\.))}, ":uuid")
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

  def test_uuid
    assert { format_request_uri("/api/isu/cbdf36e0-3417-4df6-a83d-86a3956e98c4/graph_datetime_1628521200") == "/api/isu/:uuid/graph_datetime_1628521200" }
  end
end
