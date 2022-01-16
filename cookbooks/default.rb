include_recipe "./initialize"
include_recipe "./system"
include_recipe "./user"

# NOTE: ベンチマークサーバでは以降は不要
return if node[:hostname].include?("bench")

include_recipe "./mysql"
include_recipe "./nginx"
include_recipe "./fluentd"
include_recipe "./datadog"

if node[:newrelic]
  include_recipe "./newrelic"
end

# NOTE: これが一番重いので他の作業が中断しないように一番最後に実行する
include_recipe "./ruby"
