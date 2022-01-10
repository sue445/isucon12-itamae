if node[:datadog]
  include_recipe "./enabled"
else
  include_recipe "./disabled"
end

service "datadog-agent" do
  action :nothing
end

file "/etc/datadog-agent/datadog.yaml" do
  mode "644"

  only_if "ls /etc/datadog-agent/datadog.yaml"
end

file "/etc/datadog-agent/datadog.yaml" do
  action :edit

  block do |content|
    tags_yaml = <<~YAML
      tags:
        - service:isucon

    YAML

    if content.match?(/^tags:$/)
      # tagsがあれば書き換える
      content.gsub!(/^tags:\n.+\n\n/m, tags_yaml)
    else
      # tagsがなければ末尾に追加する
      content << tags_yaml
    end
  end

  only_if "ls /etc/datadog-agent/datadog.yaml"

  notifies :restart, "service[datadog-agent]"
end

%w(
  /etc/datadog-agent/conf.d/mysql.d/
).each do |name|
  directory name do
    mode "755"
  end
end

template "/etc/datadog-agent/conf.d/mysql.d/conf.yaml" do
  mode "644"

  if node[:datadog]
    notifies :restart, "service[datadog-agent]"
  end
end
