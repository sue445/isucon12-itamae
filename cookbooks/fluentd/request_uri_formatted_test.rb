require "test/unit"

class RequestUriFormattedTest < Test::Unit::TestCase
  def format_request_uri(request_uri)
    request_uri.gsub(%r{(?<=/)[0-9]+(?=(/|$|\.))}, ":id").gsub(%r{(?<=/)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?=(/|$|\.))}, ":uuid").gsub(%r{(?<=/)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}[^/]*$}, ":uuid_with_random").gsub(%r{(?<=/)@[0-9a-zA-Z]+[^/]$}, ":at_id")
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

  def test_uuid_with_hash
    assert { format_request_uri("/api/condition/bbe0b212-d1a1-45be-bfc0-0d775af8b67f_condition_level_info_2cwarning_2ccritical_end_time_1629201367") == "/api/condition/:uuid_with_random" }
  end

  def test_at_id
    assert { format_request_uri("/@liza") == "/:at_id" }
  end
end
