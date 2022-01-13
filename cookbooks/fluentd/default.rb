include_recipe "./install-td-agent"

[
  "fluent-plugin-dogstatsd",
  "fluent-plugin-flowcounter",
  "fluent-plugin-record-reformer",
  # "fluent-plugin-typecast", # 最新で動かないので
].each do |name|
  gem_package name do
    gem_binary "td-agent-gem"
    options %w(--no-doc)
  end
end

service "td-agent" do
  action :nothing
end

directory "/etc/td-agent/conf.d" do
  owner "root"
  group "root"
  mode  "755"
end

# c.f. https://blog.takus.me/2015/10/10/datadog-with-fluentd/
%w(
  /etc/td-agent/td-agent.conf
  /etc/td-agent/conf.d/nginx.conf
  /etc/td-agent/conf.d/dogstatsd.conf
).each do |name|
  remote_file name do
    owner "root"
    group "root"
    mode  "644"

    notifies :restart, "service[td-agent]"
  end
end
