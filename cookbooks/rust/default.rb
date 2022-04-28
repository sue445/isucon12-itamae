# c.f. https://www.rust-lang.org/learn/get-started

CARGO_BIN = "/home/isucon/.cargo/bin"

# c.f. https://github.com/isucon/isucon11-qualify/blob/a443b242596003515c3037540dd3e48abfa87382/provisioning/ansible/roles/langs.rust/tasks/main.yml
execute "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" do
  not_if "#{CARGO_BIN}/rustc --version"
  user "isucon"
end

execute "#{CARGO_BIN}/rustup update" do
  user "isucon"
end
