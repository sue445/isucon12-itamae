node.reverse_merge!(
  services: {
    active_language: "ruby",
    enabled: [],
    disabled: [],
  },
)

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

# isuconの参照実装の一覧を取得する
result = run_command("systemctl list-unit-files --type=service 'isu*'")
isucon_services = result.stdout.strip.each_line.filter_map do |line|
  if line =~ /^(isu.+\..+)\.service/
    $1
  end
end

# active_languageに書かれた言語のみを起動する
isucon_services.each do |name|
  if name.end_with?(".#{node[:services][:active_language]}") && !node[:hostname].include?("bench")
    service name do
      action [:start, :enable]
    end
  else
    service name do
      action [:stop, :disable]
    end
  end
end
