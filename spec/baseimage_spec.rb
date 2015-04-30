require 'spec_helper'

context "vagrant-friendly docker baseimages" do

  context 'ubuntu-12.04' do
    file 'Vagrantfile', <<-VAGRANTFILE
Vagrant.configure(2) do |config|
  config.vm.provider "docker" do |d|
    d.image = "tknerr/baseimage-ubuntu:12.04"
    d.has_ssh = true
  end

  # use shell and other provisioners as usual
  config.vm.provision "shell", inline: "echo 'hello docker!'"
end
VAGRANTFILE

    describe "vagrant status" do
      command 'vagrant status'
      its(:stdout) { is_expected.to include('not created (docker)') }
      its(:stderr) { is_expected.to eq '' }
      its(:exitstatus) { is_expected.to eq 0 }
    end

  end
end
