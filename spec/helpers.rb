

# reopen String class to add #unindent for heredocs
# see http://stackoverflow.com/a/3772911/2388971
class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

# helper methods
module Helpers

  def write_vagrantfile_with_provisioner(dir, platform, version)
    File.write "#{dir}/Vagrantfile", vagrantfile_with_provisioner(platform, version)
  end

  def vagrantfile_with_provisioner(platform, version)
    <<-VAGRANTFILE.unindent
      Vagrant.configure(2) do |config|
        config.vm.provider "docker" do |d|
          d.image = "tknerr/baseimage-#{platform}:#{version}"
          d.has_ssh = true
        end

        # use shell and other provisioners as usual
        config.vm.provision "shell", inline: "echo 'hello docker!'"
      end
    VAGRANTFILE
  end

  def minimal_vagrantfile(platform, version)
    <<-VAGRANTFILE.unindent
    Vagrant.configure(2) do |config|
      config.vm.provider "docker" do |d|
        d.image = "tknerr/baseimage-#{platform}:#{version}"
        d.has_ssh = true
      end
    end
    VAGRANTFILE
  end

  def metadata_json
    <<-METADATA.unindent
    {
        "provider": "docker"
    }
    METADATA
  end

end
