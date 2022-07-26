require "yaml"
require "tmpdir"

ENV["SSH_USER"] ||= "isucon"

def run_itamae(hostname:, ip_address:, dry_run:)
  # node.ymlにメソッドの引数をmergeした新しいyamlを作ってitamaeを実行する
  node = YAML.load_file("node.yml")
  node["hostname"] = hostname

  Dir.mktmpdir("itamae") do |temp_dir|
    node_yaml = File.join(temp_dir, "node.yml")
    File.open(node_yaml, "wb") do |f|
      f.write(node.to_yaml)
    end

    log_level = ENV["LOG_LEVEL"] || "info"

    command = [
      "itamae",
      "ssh",
      "--user", ENV["SSH_USER"],
      "--host", ip_address,
      "--node-yaml", node_yaml,
      "--log-level", log_level,
      "cookbooks/default.rb"
    ]

    if dry_run
      command << "--dry-run"
    end

    sh command.join(" ")
  end
end

def hosts
  @hosts ||= YAML.load_file("hosts.yml")
end

def node
  @node ||= YAML.load_file("node.yml")
end

namespace :itamae do
  hosts = YAML.load_file("hosts.yml")
  hosts.each do |name, data|
    namespace name do
      desc "Run Itamae to #{name} (dry-run)"
      task :dry_run do
        run_itamae(hostname: data["hostname"], ip_address: data["ip_address"], dry_run: true)
      end

      desc "Run Itamae to #{name}"
      task :apply do
        run_itamae(hostname: data["hostname"], ip_address: data["ip_address"], dry_run: false)
      end
    end
  end

  namespace :all do
    desc "Run Itamae to all hosts (dry-run)"
    task :dry_run => hosts.keys.map { |host| "itamae:#{host}:dry_run" }

    desc "Run Itamae to all hosts"
    multitask :apply => hosts.keys.map { |host| "itamae:#{host}:apply" }
  end
end

desc "Print all server's public keys"
task :print_public_keys do
  public_keys =
    hosts.map do |_, v|
      ip_address = v["ip_address"]
      `ssh #{ENV["SSH_USER"]}@#{ip_address} cat /home/#{ENV["SSH_USER"]}/.ssh/id_ed25519.pub`.strip
    end

  puts public_keys.join("\n")
end

desc "Print ruby versions in all hosts"
task :print_ruby_versions do
  version_command = "/home/isucon/local/ruby/versions/#{node["ruby"]["version"]}/bin/ruby --version"
  if node["ruby"]["enabled_yjit"]
    version_command << " --yjit"
  end

  hosts.reject{ |k, _| k.include?("bench") }.each do |k, v|
    puts "[#{k}]"
    ip_address = v["ip_address"]
    version = `ssh #{ENV["SSH_USER"]}@#{ip_address} #{version_command}`.strip
    puts version
  end
end

def itamae_container_name
  @itamae_container_name ||=
    `docker ps`.each_line.
      find { |line| %w(isucon-itamae_app_1 isucon-itamae-app-1).any?{ |name| line.include?(name) } }&.split(" ")&.first
end

namespace :test do
  desc "Boot container"
  task :boot do
    sh "docker-compose up --build -d"
  end

  desc "Run itamae"
  task :itamae do
    raise "Not found isucon-itamae_app_1" unless itamae_container_name

    log_level = ENV["LOG_LEVEL"] || "info"

    %w(
      test/cookbooks/default.rb
      cookbooks/default.rb
    ).each do |recipe_file|
      command = [
        "itamae",
        "docker",
        "--container", itamae_container_name,
        "--tag", "itamae:latest",
        "--tmp-dir", "/var/tmp/itamae_tmp",
        "--node-yaml", "test/node.yml",
        "--log-level", log_level,
        recipe_file,
      ]
      sh command.join(" ")
    end
  end

  desc "Clean a docker container for test"
  task :clean do
    if itamae_container_name
      sh "docker rm -f #{itamae_container_name}"
    end
  end
end

desc "Run test"
task :test => ["test:boot", "test:itamae", "test:clean"]
