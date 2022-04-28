home_dir = "/home/isucon"

node[:gem][:install] ||= []

git node[:xbuild][:path] do
  repository "https://github.com/tagomoris/xbuild.git"
  user       "isucon"
end

# .c.f. https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint
%w(
  autoconf
  bison
  build-essential
  libssl-dev
  libyaml-dev
  libreadline6-dev
  zlib1g-dev
  libncurses5-dev
  libffi-dev
  libgdbm6
  libgdbm-dev
  libdb-dev
).each do |name|
  package name
end

# xbuildで最新のrubyを入れる
if node.dig(:ruby, :version)
  options = ""
  if Gem::Version.create(node[:ruby][:version]) >= Gem::Version.create("3.2.0-dev")
    options << "RUBY_CONFIGURE_OPTS=--enable-yjit PATH=/home/isucon/.cargo/bin:$PATH "
  end

  execute "#{options}#{node[:xbuild][:path]}/ruby-install #{node[:ruby][:version]} #{home_dir}/local/ruby" do
    user "isucon"

    not_if "#{node[:ruby][:binary]} --version | grep #{node[:ruby][:version]}"
  end
end

node[:gem][:install].each do |gem_name, gem_version|
  gem_package gem_name do
    gem_binary node[:gem][:binary]
    options    "--no-doc"
    user       "isucon"

    if gem_version
      version gem_version
    end
  end
end
