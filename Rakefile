
PLATFORMS = {
  ubuntu: ["12.04", "14.04"]
}

desc "buil the base images"
task :build do
  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|
      image = "tknerr/baseimage-#{platform}:#{version}"
      dir = "#{platform}-#{version.delete('.')}"
      sh "docker build -t #{image} #{dir}"
    end
  end
end

desc "run integration tests"
task :test do
  sh "rspec --format doc --color"
  #sh "cd ./ubuntu-1204 && vagrant up"
  #sh "cd ./ubuntu-1204 && vagrant ssh -c pwd"
  #sh "cd ./ubuntu-1204 && vagrant provision"
  #sh "cd ./ubuntu-1204 && vagrant destroy -f"
end
