#!/bin/bash -xe

readonly NODE_FILE="test/node_build_ruby.yml"
readonly BUNDLE=$(which bundle)

sudo ${BUNDLE} exec itamae local --node-yaml $NODE_FILE test/cookbooks/default.rb
sudo COOKBOOK="rust,ruby" ${BUNDLE} exec itamae local --node-yaml $NODE_FILE cookbooks/default.rb

/home/isucon/.cargo/bin/rustc --version
/home/isucon/local/ruby/versions/${XBUILD_RUBY_VERSION}/bin/ruby --yjit -ve 'p RubyVM::YJIT.enabled?'
