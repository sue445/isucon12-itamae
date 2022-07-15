#!/bin/bash -xe

readonly NODE_FILE="/tmp/node.yml"
readonly BUNDLE=$(which bundle)
readonly RUST_VERSION="1.58.1"

cat << YAML > $NODE_FILE
ruby:
  version: ${XBUILD_RUBY_VERSION}
  enabled_yjit: true
  minimum_rust_version: ${RUST_VERSION}

rust:
  user: isucon
  version: ${RUST_VERSION}
  rustup_install_option: "--profile minimal"
YAML

sudo ${BUNDLE} exec itamae local --node-yaml $NODE_FILE test/cookbooks/default.rb
sudo COOKBOOK="rust,ruby" ${BUNDLE} exec itamae local --node-yaml $NODE_FILE cookbooks/default.rb

/home/isucon/.cargo/bin/rustc --version
/home/isucon/local/ruby/versions/${XBUILD_RUBY_VERSION}/bin/ruby --yjit -ve 'p RubyVM::YJIT.enabled?'
