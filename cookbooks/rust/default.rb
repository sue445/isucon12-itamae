# c.f. https://www.rust-lang.org/learn/get-started

CARGO_BIN = "/home/isucon/.cargo/bin"

execute "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" do
  not_if "#{CARGO_BIN}/rustc --version"
  user "isucon"
end

execute "#{CARGO_BIN}/rustup update #{node[:rust][:version]}" do
  not_if "#{CARGO_BIN}/rustc --version | grep #{node[:rust][:version]}"
  user "isucon"
end
