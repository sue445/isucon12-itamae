execute "nginx -t && systemctl restart nginx" do
  action :nothing
end

%w(
  nginx_status.conf
).each do |file|
  remote_file "/etc/nginx/conf.d/#{file}" do
    owner "root"
    group "root"
    mode  "644"

    notifies :run, "execute[nginx -t && systemctl restart nginx]"
  end
end
