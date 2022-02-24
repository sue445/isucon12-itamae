execute "systemctl daemon-reload" do
  action :nothing
end

service "mysql" do
  action :nothing
end

# FIXME: GitHub ActionsのDockerだとread timeout reached (Docker::Error::TimeoutError)になるためDockerでは再起動を抑制する
enable_mysql_restart = !node[:docker]

# LimitNOFILEが設定されていないとmax_connectionsが増やせないので増やす
%w(mysql mariadb).each do |name|
  file "/lib/systemd/system/#{name}.service" do
    action :edit

    limit_no_file = 65535

    block do |content|
      unless content.include?("LimitNOFILE=")
        content.gsub!(/^\[Service\]/, "[Service]\nLimitNOFILE=#{limit_no_file}")
      end

      content.gsub!(/^LimitNOFILE=.+$/, "LimitNOFILE=#{limit_no_file}")
    end

    only_if "ls /lib/systemd/system/#{name}.service"

    notifies :run, "execute[systemctl daemon-reload]"

    if enable_mysql_restart
      notifies :restart, "service[mysql]"
    end
  end
end

# DatadogからMySQLのログにアクセスできるようにする
# c.f. https://docs.datadoghq.com/ja/integrations/mysql/?tab=host
%w(
  /etc/mysql/conf.d/mysqld_safe_syslog.cnf
  /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf
).each do |name|
  file name do
    action :delete

    if enable_mysql_restart
      notifies :restart, "service[mysql]"
    end
  end
end

directory "/var/log/mysql/" do
  mode "2755"
end

%w(error slow).each do |name|
  file "/var/log/mysql/#{name}.log" do
    mode "664"
  end
end

template "/etc/mysql/conf.d/isucon.cnf" do
  mode  "644"
  owner "root"
  group "root"

  variables(
    slow_query_log_file: node.dig(:mysql, :slow_query_log_file),
    long_query_time: node.dig(:mysql, :long_query_time),
    mysql_short_version: node[:mysql][:short_version],
  )

  if enable_mysql_restart
    notifies :restart, "service[mysql]"
  end
end

# Datadogで使うmysqlのユーザを作成する
# c.f.
# * https://docs.datadoghq.com/ja/integrations/mysql/
# * https://docs.datadoghq.com/ja/database_monitoring/setup_mysql/selfhosted/

define :mysql_command, check_command: nil, expected_response: nil do
  check_command = params[:check_command]
  expected_response = params[:expected_response]

  execute %Q(mysql --execute="#{params[:name]}") do
    if check_command && expected_response
      not_if %Q(mysql --execute="#{check_command}" | grep "#{expected_response}")
    end
  end
end

define :execute_sql do
  execute "mysql < /etc/isucon-itamae/#{params[:name]}"
end

directory "/etc/isucon-itamae/" do
  mode  "755"
  owner "root"
  group "root"
end

%w(
  create_datadog_schema.sql
  create_datadog_user_mysql_5.7.sql
  create_datadog_user_mysql_8.0.sql
).each do |file|
  remote_file "/etc/isucon-itamae/#{file}" do
    mode  "644"
    owner "root"
    group "root"
  end
end

if node[:mysql][:short_version] >= 8.0
  execute_sql "create_datadog_user_mysql_8.0.sql"
else
  execute_sql "create_datadog_user_mysql_5.7.sql"
end

execute_sql "create_datadog_schema.sql"
