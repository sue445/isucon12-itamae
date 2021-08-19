Dir["cookbooks/*"].sort.map { |name| name.gsub("cookbooks/", "") }.each do |name|
  include_recipe name
end
