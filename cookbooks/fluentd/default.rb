include_recipe "./install-td-agent"

template "/etc/td-agent/td-agent.conf" do
  owner "root"
  group "root"
  mode  "644"
end
