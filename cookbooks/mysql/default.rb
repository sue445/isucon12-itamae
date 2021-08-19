# LimitNOFILEが設定されていないとmax_connectionsが増やせないので増やす
file "/lib/systemd/system/mysql.service" do
  action :edit

  block do |content|
    unless content.include?("LimitNOFILE=")
      content.gsub!(/^\[Service\]/, "[Service]\nLimitNOFILE=65535")
    end

    content.gsub!(/^LimitNOFILE=.+$/, "LimitNOFILE=65535")
  end

  only_if "ls /lib/systemd/system/mysql.service"
end
