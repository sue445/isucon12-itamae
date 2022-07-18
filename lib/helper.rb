def enabled_rust_yjit?
  node.dig(:ruby, :version) && Gem::Version.create(node[:ruby][:version]) >= Gem::Version.create("3.2.0-dev") && node[:ruby][:enabled_yjit]
end
