CREATE USER IF NOT EXISTS 'datadog'@'localhost' IDENTIFIED WITH mysql_native_password by 'datadog';
ALTER USER 'datadog'@'localhost' WITH MAX_USER_CONNECTIONS 5;
GRANT REPLICATION CLIENT ON *.* TO 'datadog'@'localhost';
GRANT PROCESS ON *.* TO 'datadog'@'localhost';
GRANT SELECT ON performance_schema.* TO 'datadog'@'localhost';
