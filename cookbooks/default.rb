include_recipe "./system"
include_recipe "./mysql"
include_recipe "./user"

if node[:newrelic]
  include_recipe "./newrelic"
end

# NOTE: ベンチマークサーバではrubyは不要
unless node[:hostname].include?("bench")
  # NOTE: これが一番重いので他の作業が中断しないように一番最後に実行する
  include_recipe "./ruby"
end
