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

The following baseboxes are currently published on [Vagrant Cloud](https://app.vagrantup.com/boxes/search):

 * [`tknerr/baseimage-ubuntu-22.04`](https://app.vagrantup.com/tknerr/boxes/baseimage-ubuntu-22.04)
 * [`tknerr/baseimage-ubuntu-20.04`](https://app.vagrantup.com/tknerr/boxes/baseimage-ubuntu-20.04)
 * [`tknerr/baseimage-ubuntu-18.04`](https://app.vagrantup.com/tknerr/boxes/baseimage-ubuntu-18.04)
 * [`tknerr/baseimage-ubuntu-16.04`](https://app.vagrantup.com/tknerr/boxes/baseimage-ubuntu-16.04)
 * [`tknerr/baseimage-ubuntu-14.04`](https://app.vagrantup.com/tknerr/boxes/baseimage-ubuntu-14.04)

### Usage

Use the `config.vm.box` setting to specify the basebox in your Vagrantfile.

For example, run `vagrant init tknerr/baseimage-ubuntu-22.04 --minimal` to create the Vagrantfile below:
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "tknerr/baseimage-ubuntu-22.04"
end
```

Then, running `vagrant up --provider docker` should look similar to this:
```
W:\repo\sample>vagrant up --provider=docker
Bringing machine 'default' up with 'docker' provider...
==> default: Creating the container...
    default:   Name: minimal_default_1441605508
    default:  Image: tknerr/baseimage-ubuntu:22.04
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

## Docker Base Images

In case you want to work with the actual docker base images directly, the following ones (see subdirectories) are available on [docker hub](https://registry.hub.docker.com):

 * [`tknerr/baseimage-ubuntu:22.04`](https://hub.docker.com/r/tknerr/baseimage-ubuntu/tags/)
 * [`tknerr/baseimage-ubuntu:20.04`](https://hub.docker.com/r/tknerr/baseimage-ubuntu/tags/)
 * [`tknerr/baseimage-ubuntu:18.04`](https://hub.docker.com/r/tknerr/baseimage-ubuntu/tags/)
 * [`tknerr/baseimage-ubuntu:16.04`](https://hub.docker.com/r/tknerr/baseimage-ubuntu/tags/)
 * [`tknerr/baseimage-ubuntu:14.04`](https://hub.docker.com/r/tknerr/baseimage-ubuntu/tags/)

### Usage

You can use it in your Vagrantfile in it's most simple form like this and then
run `vagrant up`:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:22.04"
  end
end
```

If you want to use provisioners, you need to additionally tell vagrant that
this container has ssh enabled:
```ruby
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:22.04"
    d.has_ssh = true
  end

  # use shell and other provisioners as usual
  config.vm.provision "shell", inline: "echo 'hello docker!'"
end
```

## Development

### Prerequisites

Prerequisites you need to have installed:

* Docker
* Vagrant
* Ruby

### Building and Testing

Install bundler dependencies first:
```
$ bundle install --path vendor/bundle
```

To build the Docker Base Images for Ubuntu 22.04:
```
$ bundle exec rake build:docker:base_images PLATFORM=ubuntu-22.04
```

Run integration tests for the Docker Base Image:
```
$ bundle exec rake test:docker:base_images PLATFORM=ubuntu-22.04
rspec --format doc --color --tty spec/baseimage_spec.rb

vagrant-friendly docker baseimages
  ubuntu-22.04
    is referenced in a `Vagrantfile` as a docker image
    is not created when I run `vagrant status`
    comes up when I run `vagrant up --no-provision`
    is now shown as running when I run `vagrant status` again
    accepts remote ssh commands via `vagrant ssh -c`
    can be provisioned with a shell script via `vagrant provision`
    is DISTRIB_ID=Ubuntu / DISTRIB_RELEASE=22.04 in lsb-release file
    can be stopped via `vagrant halt`
    can be destroyed via `vagrant destroy`

Finished in 46.74 seconds (files took 0.31354 seconds to load)
9 examples, 0 failuress
```

In order to build the Vagrant Basebox "wrappers" around it:
```
$ bundle exec rake build:vagrant:baseboxes PLATFORM=ubuntu-22.04
```

Run integration tests for the Vagrant Basebox:
```
$ bundle exec rake test:vagrant:baseboxes PLATFORM=ubuntu-22.04
rspec --format doc --color --tty spec/basebox_spec.rb

base boxes for the docker baseimages
  tknerr/baseimage-ubuntu-22.04
    is referenced in a `Vagrantfile` as a basebox
    can be imported via `vagrant box add`
    comes up via `vagrant up --provider docker`
    can be destroyed via `vagrant destroy`

Finished in 30.08 seconds (files took 0.61239 seconds to load)
4 examples, 0 failures
```

### Publishing

This is currently done manually, and requires to log in to dockerhub / vagrantcloud interactively.

To publish the docker base image for Ubuntu 22.04 to dockerhub:
```
$ bundle exec rake publish:docker:base_images PLATFORM=ubuntu-22.04
```

To publish the corresponding vagrant basebox to vagrantcloud:
```
$ bundle exec rake publish:vagrant:baseboxes PLATFORM=ubuntu-22.04
```

## Contributing

How to contribute?

 1. fork this repo
 2. create a new branch with your changes
 3. submit a pull request

## License

MIT - see the accompanying [LICENSE](https://github.com/tknerr/vagrant-docker-baseimages/blob/master/LICENSE) file
