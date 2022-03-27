node[:services][:enabled] ||= []
node[:services][:disabled] ||= []

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
