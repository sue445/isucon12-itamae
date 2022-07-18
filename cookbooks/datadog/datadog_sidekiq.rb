node.reverse_merge!(
  datadog_sidekiq: {
    version: "v0.0.10",
  },
)

archive_name = "datadog-sidekiq_#{node[:datadog_sidekiq][:version]}_linux_amd64.tar.gz"

http_request "/usr/local/src/#{archive_name}" do
  url "https://github.com/feedforce/datadog-sidekiq/releases/download/#{node[:datadog_sidekiq][:version]}/#{archive_name}"
end

execute "tar zfx /usr/local/src/#{archive_name} datadog-sidekiq" do
  cwd "/usr/local/bin"
  not_if "/usr/local/bin/datadog-sidekiq --version | grep #{node[:datadog_sidekiq][:version]}"
end

file "/usr/local/bin/datadog-sidekiq" do
  owner "root"
  group "root"
  mode "755"
end
