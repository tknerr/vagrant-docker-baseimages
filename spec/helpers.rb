

# reopen String class to add #unindent for heredocs
# see http://stackoverflow.com/a/3772911/2388971
class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

# helper methods
module Helpers

  def write_config(dir, content)
    File.write "#{dir}/Vagrantfile", content
  end

  def os
    ENV.fetch('OS_UNDER_TEST')
  end

  def version
    ENV.fetch('VERSION_UNDER_TEST')
  end

  def vagrantfile_referencing_docker_baseimage(os, version)
    <<~VAGRANTFILE
      Vagrant.configure(2) do |config|
        config.vm.provider "docker" do |d|
          d.image = "tknerr/baseimage-#{os}:#{version}"
          d.has_ssh = true
        end

        # use shell and other provisioners as usual
        config.vm.provision "shell", inline: "echo 'hello docker!'"
      end
    VAGRANTFILE
  end

  def vagrantfile_referencing_local_basebox(os, version)
    <<~VAGRANTFILE
      Vagrant.configure(2) do |config|
        config.vm.box = "tknerr/baseimage-#{os}-#{version}"
        config.vm.box_version = "0"
      end
    VAGRANTFILE
  end

end
