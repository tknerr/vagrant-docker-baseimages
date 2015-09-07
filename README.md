# Vagrant-friendly Docker Base Images

[![Circle CI](https://circleci.com/gh/tknerr/vagrant-docker-baseimages/tree/master.svg?style=shield)](https://circleci.com/gh/tknerr/vagrant-docker-baseimages/tree/master)

A collection of Vagrant-friendly docker base images + corresponding Vagrant baseboxes. Something inbetween the
official distro base image and [puhsion/baseimage](https://phusion.github.io/baseimage-docker/),
just enough to make it work with Vagrant.

On top of the official distro base image it includes:

 * the `vagrant` user (password `vagrant`) with passwordless sudo enabled
 * the vagrant insecure public key in `~/.ssh/authorized_keys`
 * `sshd` running in the foreground


## Vagrant Baseboxes

The intended use of the Vagrant-friendly docker base images is to use them as a basebox in your `Vagrantfile`. These baseboxes simply reference one of the [actual docker base images](https://github.com/tknerr/vagrant-docker-baseimages#docker-base-images) below.

The following baseboxes are currently published on [Atlas](https://atlas.hashicorp.com/boxes/search):

 * [`tknerr/baseimage-ubuntu-12.04`](https://atlas.hashicorp.com/tknerr/boxes/baseimage-ubuntu-12.04)
 * [`tknerr/baseimage-ubuntu-14.04`](https://atlas.hashicorp.com/tknerr/boxes/baseimage-ubuntu-14.04)

### Usage

Use the `config.vm.box` setting to specify the basebox in your Vagrantfile.

For example, run `vagrant init tknerr/baseimage-ubuntu-14.04 --minimal` to create the Vagrantfile below:
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "tknerr/baseimage-ubuntu-14.04"
end
```

Then, running `vagrant up --provider docker` should look similar to this:
```
W:\repo\sample>vagrant up --provider=docker
Bringing machine 'default' up with 'docker' provider...
==> default: Creating the container...
    default:   Name: minimal_default_1441605508
    default:  Image: tknerr/baseimage-ubuntu:14.04
    default: Volume: /w/repo/sample:/vagrant
    default:   Port: 0.0.0.0:2222:22
    default:
    default: Container created: f366398390f6b33f
==> default: Starting container...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 192.168.59.104:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
```

### Warning - it might not work as expected (Vagrant =< 1.7.2)

> **Please note**: until version 1.7.2 of Vagrant the docker provisioner [does not inspect
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


## Docker Base Images

In case you want to work with the actual docker base images directly, the following ones (see subdirectories) are available on [docker hub](https://registry.hub.docker.com):

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


## Contribute

How to contribute?

 1. fork this repo
 2. create a new branch with your changes
 3. submit a pull request

## License

MIT - see the accompanying [LICENSE](https://github.com/tknerr/vagrant-docker-baseimages/blob/master/LICENSE) file
