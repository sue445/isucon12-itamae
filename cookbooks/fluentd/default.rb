include_recipe "./install-td-agent"

%w(
  fluent-plugin-dogstatsd
).each do |name|
  gem_package name do
    gem_binary "td-agent-gem"
    options %w(--no-doc)
  end
end

service "td-agent" do
  action :nothing
end

template "/etc/td-agent/td-agent.conf" do
  owner "root"
  group "root"
  mode  "644"

  notifies :restart, "service[td-agent]"
end
