require 'spec_helper'

describe 'vagrant-friendly docker baseimages' do

  describe 'ubuntu-12.04' do

    it 'is not started when I run `vagrant status`' do

      Dir.mktmpdir do |dir|
        File.write "#{dir}/Vagrantfile", <<-VAGRANTFILE.unindent
          Vagrant.configure(2) do |config|
            config.vm.provider "docker" do |d|
              d.image = "tknerr/baseimage-ubuntu:12.04"
              d.has_ssh = true
            end

            # use shell and other provisioners as usual
            config.vm.provision "shell", inline: "echo 'hello docker!'"
          end
        VAGRANTFILE

        cmd = Mixlib::ShellOut.new("vagrant status", :cwd => dir)
        res = cmd.run_command
        expect(res.stdout).to include "not created (docker)"
        expect(res.stderr).to match ""
        expect(res.status.exitstatus).to eq 0
      end
    end
  end
end
