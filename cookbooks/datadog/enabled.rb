require "dotenv/load"

node[:datadog][:api_key] = ENV["DD_API_KEY"]
node[:datadog][:integration] ||= {}

include_recipe "datadog::install"

service "datadog-agent" do
  action [:start, :enable]
end
