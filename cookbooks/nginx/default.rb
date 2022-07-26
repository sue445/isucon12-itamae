package "nginx"

service "nginx" do
  action [:start, :enable]
end

execute "nginx -t && systemctl restart nginx" do
  action :nothing
end

%w(
  log_format_datadog.conf
  log_format_ltsv.conf
  nginx_status.conf
).each do |file|
  remote_file "/etc/nginx/conf.d/#{file}" do
    owner "root"
    group "root"
    mode  "644"

    notifies :run, "execute[nginx -t && systemctl restart nginx]"
  end
end

%w(
  access.log
  access_ltsv.log
  error.log
).each do |name|
  file "/var/log/nginx/#{name}" do
    mode "644"
  end
end