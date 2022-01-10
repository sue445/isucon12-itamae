execute "systemctl daemon-reload" do
  action :nothing
end

service "mysql" do
  action :nothing
end

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
    notifies :restart, "service[mysql]"
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
    notifies :restart, "service[mysql]"
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
  )

  notifies :restart, "service[mysql]"
end

# Datadogで使うmysqlのユーザを作成する
# c.f. https://docs.datadoghq.com/ja/integrations/mysql/

define :mysql_command, check_command: nil, expected_response: nil do
  check_command = params[:check_command]
  expected_response = params[:expected_response]

  execute %Q(mysql --execute="#{params[:name]}") do
    if check_command && expected_response
      not_if %Q(mysql --execute="#{check_command}" | grep "#{expected_response}")
    end
  end
end

mysql_command "CREATE USER 'datadog'@'localhost' IDENTIFIED BY 'datadog'" do
  check_command     "SELECT user FROM mysql.user WHERE user = 'datadog' AND host = 'localhost'"
  expected_response "datadog"
end

if node[:mysql][:short_version] < 8.0
  # MySQL 8未満の場合
  mysql_command "GRANT REPLICATION CLIENT ON *.* TO 'datadog'@'localhost' WITH MAX_USER_CONNECTIONS 5" do
    check_command     "SELECT Repl_client_priv FROM mysql.user WHERE user = 'datadog' AND host = 'localhost'"
    expected_response "Y"
  end

  mysql_command "GRANT PROCESS ON *.* TO 'datadog'@'localhost'" do
    check_command     "SELECT Process_priv FROM mysql.user WHERE user = 'datadog' AND host = 'localhost'"
    expected_response "Y"
  end
else
  # MySQL 8以上の場合
  mysql_command "ALTER USER 'datadog'@'localhost' WITH MAX_USER_CONNECTIONS 5" do
    check_command     "SELECT max_user_connections FROM mysql.user WHERE user = 'datadog' AND host = 'localhost'"
    expected_response "5"
  end
end
