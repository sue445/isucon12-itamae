require "dotenv/load"

node[:datadog][:api_key] = ENV["DD_API_KEY"]
node[:datadog][:integration] ||= {}

include_recipe "datadog::install"

service "datadog-agent" do
  action [:start, :enable]
end

node[:datadog][:integration].each do |name, version|
  execute "datadog-agent integration install -t #{name}==#{version} --allow-root" do
    not_if "datadog-agent integration show #{name} | grep #{version}"
  end
end
