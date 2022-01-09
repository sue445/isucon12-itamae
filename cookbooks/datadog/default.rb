require "dotenv/load"

node[:datadog][:api_key] = ENV["DD_API_KEY"]

include_recipe "datadog::install"

service "datadog-agent" do
  action [:start, :enable]
end

file "/etc/datadog-agent/datadog.yaml" do
  mode "644"
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

  notifies :restart, "service[datadog-agent]"
end
