file "/etc/newrelic-infra.yml" do
  action :edit

  block do |content|
    unless content.include?("enable_process_metrics")
      content << <<~YAML
        enable_process_metrics: true
      YAML
    end
  end
end
