git node[:xbuild][:path] do
  repository "https://github.com/tagomoris/xbuild.git"
  user       "isucon"
end

# xbuildで最新のrubyを入れる
if node.dig(:ruby, :version)
  execute "#{node[:xbuild][:path]}/ruby-install #{node[:ruby][:version]} #{home_dir}/local/ruby" do
    user "isucon"

    not_if "#{node[:ruby][:binary]} --version | grep #{node[:ruby][:version]}"
  end
end

node[:gem][:install].each do |name|
  gem_package name do
    gem_binary node[:gem][:binary]
    options    "--no-doc"
    user       "isucon"
  end
end
