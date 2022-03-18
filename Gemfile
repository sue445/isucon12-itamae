# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "dotenv"
gem "itamae"

# TODO: gemがリリースまでの暫定
# gem "itamae-plugin-recipe-datadog"
gem "itamae-plugin-recipe-datadog", github: "speee/itamae-plugin-recipe-datadog", branch: "master"

gem "rake"

group :test do
  # required for `itamae docker`
  # c.f. https://github.com/itamae-kitchen/itamae/blob/v1.12.1/lib/itamae/backend.rb#L307-L311
  gem "docker-api"
end
