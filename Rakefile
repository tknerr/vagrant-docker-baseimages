
desc "buil the base images"
task :build do
  sh "docker build -t tknerr/baseimage-ubuntu:12.04 ubuntu-1204"
  sh "docker build -t tknerr/baseimage-ubuntu:14.04 ubuntu-1404"
end

desc "run integration tests"
task :test do
  sh "rspec --format doc --color"
  #sh "cd ./ubuntu-1204 && vagrant up"
  #sh "cd ./ubuntu-1204 && vagrant ssh -c pwd"
  #sh "cd ./ubuntu-1204 && vagrant provision"
  #sh "cd ./ubuntu-1204 && vagrant destroy -f"
end
