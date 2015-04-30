
desc "buil the base images"
task :build do
  system "docker build -t tknerr/baseimage-ubuntu:12.04 ubuntu-1204"
  system "docker build -t tknerr/baseimage-ubuntu:14.04 ubuntu-1404"
end

desc "run integration tests"
task :test do
  system "rspec --format doc --color"
  #system "cd ./ubuntu-1204 && vagrant up"
  #system "cd ./ubuntu-1204 && vagrant ssh -c pwd"
  #system "cd ./ubuntu-1204 && vagrant provision"
  #system "cd ./ubuntu-1204 && vagrant destroy -f"
end
