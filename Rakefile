
desc "buil the base images"
task :build do
  system "docker build -t tknerr/baseimage-ubuntu:12.04 ubuntu-1204"
  system "docker build -t tknerr/baseimage-ubuntu:14.04 ubuntu-1404"
end

desc "run integration tests"
task :test do
  File.write("./ubuntu-1204/Vagrantfile", <<-VAGRANTFILE
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:12.04"
    d.has_ssh = true
  end

  # use shell and other provisioners as usual
  config.vm.provision "shell", inline: "echo 'hello docker!'"
end
VAGRANTFILE
)
  system "cd ./ubuntu-1204 && vagrant up"
  system "cd ./ubuntu-1204 && vagrant ssh -c pwd"
  system "cd ./ubuntu-1204 && vagrant provision"
  system "cd ./ubuntu-1204 && vagrant destroy -f"
end
