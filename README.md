# Vagrant-friendly Docker Base Images

[![Circle CI](https://circleci.com/gh/tknerr/vagrant-docker-baseimages/tree/master.svg?style=shield)](https://circleci.com/gh/tknerr/vagrant-docker-baseimages/tree/master)

A collection of Vagrant-friendly docker base images, something inbetween the
official distro base image and [puhsion/baseimage](https://phusion.github.io/baseimage-docker/),
just enough to make it work with Vagrant.

On top of the official distro base image it includes:

 * the `vagrant` user (password `vagrant`) with passwordless sudo enabled
 * the vagrant insecure public key in `~/.ssh/authorized_keys`
 * `sshd` running in the foreground

## Docker Base Images

The following base images (see subdirectories) are available on [docker hub](https://registry.hub.docker.com):

 * [`tknerr/baseimage-ubuntu:12.04`](https://registry.hub.docker.com/u/tknerr/baseimage-ubuntu/)
 * [`tknerr/baseimage-ubuntu:14.04`](https://registry.hub.docker.com/u/tknerr/baseimage-ubuntu/)


### Usage

You can use it in your Vagrantfile in it's most simple form like this and then
run `vagrant up`:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:14.04"
  end
end
```

If you want to use provisioners, you need to additionally tell vagrant that
this container has ssh enabled:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:14.04"
    d.has_ssh = true
  end

  # use shell and other provisioners as usual
  config.vm.provision "shell", inline: "echo 'hello docker!'"
end
```

## Vagrant Baseboxes

In addition to the base images above we publish the corresponding Vagrant baseboxes on [Atlas](https://atlas.hashicorp.com/boxes/search),
which "alias" the Docker images:

 * [`tknerr/baseimage-ubuntu-12.04`](https://atlas.hashicorp.com/tknerr/boxes/baseimage-ubuntu-12.04)
 * [`tknerr/baseimage-ubuntu-14.04`](https://atlas.hashicorp.com/tknerr/boxes/baseimage-ubuntu-14.04)

They can be used in the Vagrantfile via `config.vm.box` setting directly (almost,
see the warning below).

### Warning - it might not work as you expect (yet)

> **Please note**: as of Vagrant 1.7.2 the docker provisioner [does not inspect
> the packaged Vagrantfile](https://github.com/mitchellh/vagrant/issues/5667)
> in the basebox, i.e. it might fail with an error like that:
> ```
> $ vagrant up --provider docker
> Bringing machine 'default' up with 'docker' provider...
> There are errors in the configuration of this machine. Please fix
> the following errors and try again:
>
> docker provider:
> * One of "build_dir" or "image" must be set
> ```
> As a workaround you have to import the desired basebox once, so it is available
> locally and the docker provider can inspect the Vagrantfile [we package into the box](https://github.com/tknerr/vagrant-docker-baseimages/blob/ea692a56b5b004135f7db08c2720418ad8bfc9a4/spec/helpers.rb#L34-38):
> ```
> $ vagrant box add tknerr/baseimage-ubuntu-14.04
> ```
> After that, you can use the `config.vm.box` with the docker baseimage as expected.

### Usage

You can use the `config.vm.box` setting and then run `vagrant up --provider docker`:
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "tknerr/baseimage-ubuntu-14.04"
end
```

## Contribute

How to contribute?

 1. fork this repo
 2. create a new branch with your changes
 3. submit a pull request

## License

MIT - see the accompanying [LICENSE](https://github.com/tknerr/vagrant-docker-baseimages/blob/master/LICENSE) file
