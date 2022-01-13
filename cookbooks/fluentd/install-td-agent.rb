case node[:platform]
when "ubuntu"
  # c.f. https://docs.fluentd.org/installation/install-by-deb
  if node[:platform_version] >= '20.04'
    # Focal
    execute "curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh" do
      not_if "systemctl list-unit-files --type=service | grep td-agent"
    end
  else
    raise NotImplementedError, "Platform version'#{node[:platform_version]}' is not supported by fluentd/td-agent yet"
  end
else
  raise NotImplementedError, "Platform '#{node[:platform]}' is not supported by fluentd/td-agent yet"
end
