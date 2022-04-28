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
  install_options = ""
  check_command = ""

  # NOTE: ruby-buildで3.2.0-devをインストールした場合、ruby -vでは3.2.0devが出力されるため
  command_ruby_version = node[:ruby][:version].gsub("-", "")

  if Gem::Version.create(node[:ruby][:version]) >= Gem::Version.create("3.2.0-dev") && node[:ruby][:enabled_yjit]
    install_options << "RUBY_CONFIGURE_OPTS=--enable-yjit PATH=/home/isucon/.cargo/bin:$PATH "

    # NOTE: Ruby 3.2.0以降ではYJITを有効にしてビルドしてるかもチェックする
    check_command = %Q{bash -c '( #{node[:ruby][:binary]} --version | grep #{command_ruby_version} ) && ( #{node[:ruby][:binary]} --yjit -e "p RubyVM::YJIT.enabled?" | grep "true")'}
  else
    check_command = "#{node[:ruby][:binary]} --version | grep #{command_ruby_version}"
  end

  execute "#{install_options}#{node[:xbuild][:path]}/ruby-install #{node[:ruby][:version]} #{home_dir}/local/ruby" do
    user "isucon"

    not_if check_command
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
