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
    task :apply => hosts.keys.map { |host| "itamae:#{host}:apply" }
  end
end
