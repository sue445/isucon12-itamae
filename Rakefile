require "yaml"
require "tmpdir"

def run_itamae(hostname:, ip_address:, dry_run:)
  # node.ymlにメソッドの引数をmergeした新しいyamlを作ってitamaeを実行する
  node = YAML.load_file("node.yml")
  node["hostname"] = hostname

  Dir.mktmpdir("itamae") do |temp_dir|
    node_yaml = File.join(temp_dir, "node.yml")
    File.open(node_yaml, "wb") do |f|
      f.write(node.to_yaml)
    end

    command = [
      "itamae",
      "ssh",
      "--user", "isucon",
      "--host", ip_address,
      "--node-yaml", node_yaml,
      "cookbooks/default.rb"
    ]

    if dry_run
      command << "--dry-run"
    end

    sh command.join(" ")
  end
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
  hosts = YAML.load_file("hosts.yml")

  public_keys =
    hosts.map do |_, v|
      ip_address = v["ip_address"]
      `ssh isucon@#{ip_address} cat /home/isucon/.ssh/id_ed25519.pub`.strip
    end

  puts public_keys.join("\n")
end

def itamae_container_name
  @itamae_container_name ||= `docker ps`.each_line.find { |line| line.include?("isucon-itamae_app_1") }.split(" ")[0]
end

namespace :test do
  desc "Boot container"
  task :boot do
    sh "docker-compose up --build -d"
  end

  desc "Run itamae"
  task :itamae do
    raise "Not found isucon-itamae_app_1" unless itamae_container_name

    command = [
      "itamae",
      "docker",
      "--container", itamae_container_name,
      "--tag", "itamae:latest",
      "--tmp-dir", "/var/tmp/itamae_tmp",
      "--node-yaml", "test/node.yml",
      "cookbooks/default.rb"
    ]
    sh command.join(" ")
  end

  desc "Clean a docker container for test"
  task :clean do
    if itamae_container_name
      sh "docker rm -f #{itamae_container_name}"
    end
  end
end

task :test => ["test:boot", "test:itamae", "test:clean"]
