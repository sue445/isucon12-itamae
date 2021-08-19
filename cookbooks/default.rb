home_dir = "/home/isucon"

# hostnameを設定
execute "hostnamectl set-hostname #{node[:hostname]}" do
  not_if "hostname | grep #{node[:hostname]}"
end

# サーバ内でgit commitできるようにuser.nameとuser.emailは最低限設定する
node[:git_global_config].each do |name, value|
  execute "git config --global #{name} '#{value}'" do
    not_if "git config --global #{name} | grep '#{value}'"
  end
end

# sshの鍵を生成する
execute %Q(ssh-keygen -t ed25519 -C "sue445@$(hostname)" -N "" -f #{home_dir}/.ssh/id_ed25519 -q) do
  not_if "ls #{home_dir}/.ssh/id_ed25519"
end

# サーバ起動後の最初の1回だけapt-get updateを実行するためにキャッシュを作る
execute "apt-get update && touch /tmp/apt-get-update" do
  not_if "ls /tmp/apt-get-update"
end

# ツールのインストール
[
  "htop",
  "tmux",
  "tig",

  # stakprof-webnavで必要
  "graphviz",
].each do |name|
  package name
end

# 自分のdotfilesにあるtmuxの設定をDL
execute "wget https://raw.githubusercontent.com/sue445/dotfiles/master/_tmux_3_x.conf -O #{home_dir}/.tmux.conf" do
  not_if "ls #{home_dir}/.tmux.conf"
end

# bashrcに設定を追加
file "#{home_dir}/.bashrc" do
  action :edit

  block do |content|
    unless content.include?("alias tm")
      content << <<~BASH
        alias tm='(tmux list-sessions || tmux -u) && tmux -u a'
      BASH
    end
  end
end

remote_file "#{home_dir}/.ssh/config"

# インストールはするがサービスは止めておく
[
  "redis-server",
  "memcached",
].each do |name|
  package name

  service name do
    action [:stop, :disable]
  end
end

git node[:xbuild][:path] do
  repository "https://github.com/tagomoris/xbuild.git"
  user       "isucon"
end

# xbuildで最新のrubyを入れる
execute "#{node[:xbuild][:path]}/ruby-install #{node[:ruby][:version]} #{home_dir}/local/ruby" do
  user "isucon"

  not_if "#{node[:ruby][:binary]} --version | grep #{node[:ruby][:version]}"
end

node[:gem][:install].each do |name|
  gem_package name do
    gem_binary node[:gem][:binary]
    options    "--no-doc"
    user       "isucon"
  end
end
