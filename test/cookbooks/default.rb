%w(
  sudo
).each do |name|
  package name
end

# ref. https://github.com/isucon/isucon11-prior/blob/main/infra/instance/cookbooks/user/default.rb
group "isucon"

user "isucon" do
  gid "isucon"
  shell "/bin/bash"
  create_home true
end

file "/etc/sudoers" do
  action :edit
  block do |content|
    line = "isucon ALL=(ALL) NOPASSWD:ALL"
    unless content.include?(line)
      content << line
      content << "\n"
    end
  end
end
