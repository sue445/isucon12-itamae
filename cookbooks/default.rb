include_recipe "./system"
include_recipe "./mysql"
include_recipe "./user"

# NOTE: これが一番重いので他の作業が中断しないように一番最後に実行する
include_recipe "./ruby"
