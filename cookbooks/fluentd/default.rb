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

# FIXME: GitHub ActionsのDockerだとなぜかtd-agentが起動できないのでDockerでは再起動を抑制する
enable_tdagent_restart = !node[:docker]

template "/etc/td-agent/td-agent.conf" do
  owner "root"
  group "root"
  mode  "644"

  if enable_tdagent_restart
    notifies :restart, "service[td-agent]"
  end
end
