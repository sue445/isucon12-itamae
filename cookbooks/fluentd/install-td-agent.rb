case node[:platform]
when "ubuntu"
  # c.f. https://docs.fluentd.org/installation/install-by-deb
  if node[:platform_version] >= '20.04'
    # Focal
    # NOTE: Dockerコンテナ内でインストールスクリプトを実行できないのでスクリプトの中身を直接実行する
    # c.f. https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh
    %w(
      curl
      gnupg2
    ).each do|name|
      package name
    end

    execute "curl https://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add -" do
      not_if "apt-key list | grep 'Treasure Agent Official Signing key'"
    end

    template "/etc/apt/sources.list.d/treasure-data.list" do
      owner "root"
      group "root"
      mode  "644"

      variables(
        platform: "ubuntu",
        version:  "focal",
      )
    end

    execute "apt-get update" do
      not_if "systemctl list-unit-files --type=service | grep td-agent"
    end

    package "td-agent"
  else
    raise NotImplementedError, "Platform version'#{node[:platform_version]}' is not supported by fluentd/td-agent yet"
  end
else
  raise NotImplementedError, "Platform '#{node[:platform]}' is not supported by fluentd/td-agent yet"
end
