# Vagrant-friendly Docker Base Images

A collection of Vagrant-friendly docker base images, something inbetween the
official distro base image and [puhsion/baseimage](https://phusion.github.io/baseimage-docker/), just enough to make it work
with Vagrant.

On top of the official distro base image it includes:

 * the `vagrant` user (password `vagrant`) with passwordless sudo enabled
 * the vagrant insecure public key in `~/.ssh/authorized_keys`
 * `sshd` running in the foreground

## Available Base Images

The following base images are available (see subdirectories):

 * [tknerr/baseimage-ubuntu-12.04](https://registry.hub.docker.com/u/tknerr/baseimage-ubuntu-12.04/)
 * tknerr/baseimage-ubuntu-14.04


## Usage

You can use it in your Vagrantfile in it's most simple form like this:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu-14.04"
  end
end
```

If you want to use provisioners, you need to additionally tell vagrant that
this container has ssh enabled:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu-14.04"
    d.has_ssh = true
  end

  # use shell and other provisioners as usual
  config.vm.provision "shell", inline: "echo 'hello docker!'"
end
```

## Contribute

How to contribute?

 1. fork this repo
 2. create a new branch with your changes
 3. submit a pull request

## License

MIT - see the accompanying [LICENSE](https://github.com/tknerr/vagrant-docker-baseimages/blob/master/LICENSE) file
