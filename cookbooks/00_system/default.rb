# hostnameを設定
execute "hostnamectl set-hostname #{node[:hostname]}" do
  not_if "hostname | grep #{node[:hostname]}"
end

# サーバ起動後の最初の1回だけapt-get updateを実行するためにキャッシュを作る
execute "apt-get update && touch /tmp/apt-get-update" do
  not_if "ls /tmp/apt-get-update"
end

# ツールのインストール
node[:packages].each do |name|
  package name
end

git node[:xbuild][:path] do
  repository "https://github.com/tagomoris/xbuild.git"
  user       "isucon"
end

# サービスのON/OFF
node[:services][:disabled].each do |name|
  service name do
    action [:stop, :disable]
  end
end

node[:services][:enabled].each do |name|
  service name do
    action [:start, :enable]
  end
end

# ulimit変更
file "/etc/security/limits.conf" do
  action :edit

  block do |content|
    unless content.include?("* soft nofile 65536")
      content << <<~EOF
        * soft nofile 65536
        * hard nofile 65536
      EOF
    end
  end

  not_if "ulimit -n | grep 65536"
end
