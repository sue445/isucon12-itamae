node.reverse_merge!(
  git_global_config: {},
)

home_dir = "/home/isucon"

# sshの鍵を生成する
execute %Q(ssh-keygen -t ed25519 -C "sue445@$(hostname)" -N "" -f #{home_dir}/.ssh/id_ed25519 -q) do
  user "isucon"

  not_if "ls #{home_dir}/.ssh/id_ed25519"
end

# 自分のdotfilesにある設定をDL
execute "wget https://raw.githubusercontent.com/sue445/dotfiles/master/_tmux_3_x.conf -O #{home_dir}/.tmux.conf" do
  user "isucon"

  not_if "ls #{home_dir}/.tmux.conf"
end

execute "wget https://raw.githubusercontent.com/sue445/dotfiles/master/_tigrc -O #{home_dir}/.tigrc" do
  user "isucon"

  not_if "ls #{home_dir}/.tigrc"
end

# bashrcに設定を追加
file "#{home_dir}/.bashrc" do
  action :edit

  block do |content|
    [
      "alias tm='(tmux list-sessions || tmux -u) && tmux -u a'",
      "alias g='git'",
      "alias gs='git status -sb'",
      "alias t='tig'",
      "alias ta='tig --all'",
    ].each do |line|
      unless content.include?(line)
        content << "#{line}\n"
      end
    end
  end
end

execute "wget https://raw.githubusercontent.com/sue445/dotfiles/master/_gitconfig -O #{home_dir}/.gitconfig" do
  user "isucon"

  not_if "ls #{home_dir}/.gitconfig"
end

template "#{home_dir}/.gitconfig.local" do
  mode "644"
  owner "isucon"
  group "isucon"

  variables(
    user_email: node[:git][:user_email],
    user_name:  node[:git][:user_name],
  )
end

remote_file "#{home_dir}/.ssh/config"

execute "cp /etc/mysql/debian.cnf #{home_dir}/.my.cnf" do
  # NOTE: /etc/mysql/debian.cnfが存在 && .my.cnf が存在しない場合のみファイルをコピーする
  only_if "test -f /etc/mysql/debian.cnf -a ! -f #{home_dir}/.my.cnf"
end

file "#{home_dir}/.my.cnf" do
  owner "isucon"
  group "isucon"
  mode  "644"
end
