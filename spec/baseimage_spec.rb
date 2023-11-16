require 'spec_helper'

describe 'vagrant-friendly docker baseimages' do

  before(:all) do
    @tempdir = Dir.mktmpdir
    ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
  end

  after(:all) do
    FileUtils.rm_rf @tempdir
  end

  describe "#{docker_image_name(os, version)} (for #{arch})" do
    it "is present as a docker image for #{arch}" do
      result = run_command("docker images #{docker_image_name(os, version)} --format '{{.Repository}}:{{.Tag}}, built {{.CreatedSince}}'")
      expect(result.stdout).to include "#{docker_image_name(os, version)},"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
      result2 = run_command("docker image inspect #{docker_image_name(os, version)} --format '{{.Architecture}}'")
      expect(result2.stdout).to match arch
      expect(result2.stderr).to match ""
      expect(result2.status.exitstatus).to eq 0
    end
    it 'is referenced in a `Vagrantfile` as a docker image' do
      write_config(@tempdir, vagrantfile_referencing_docker_baseimage(os, version))
      expect(File.read("#{@tempdir}/Vagrantfile")).to include <<~SNIPPET
        d.image = "#{docker_image_name(os, version)}"
      SNIPPET
    end
    it 'is not created when I run `vagrant status`' do
      result = run_command("vagrant status", :cwd => @tempdir)
      expect(result.stdout).to include "not created (docker)"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it 'comes up when I run `vagrant up --no-provision`' do
      result = run_command("vagrant up --no-provision", :cwd => @tempdir)
      expect(result.stdout).to include "Image: #{docker_image_name(os, version)}"
      expect(result.stdout).to include "==> default: Machine booted and ready!"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it 'is now shown as running when I run `vagrant status` again' do
      result = run_command("vagrant status", :cwd => @tempdir)
      expect(result.stdout).to include "running (docker)"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it 'accepts remote ssh commands via `vagrant ssh -c`' do
      result = run_command("vagrant ssh -c pwd", :cwd => @tempdir)
      expect(result.stdout).to include "/home/vagrant"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it 'can be provisioned with a shell script via `vagrant provision`' do
      result = run_command("vagrant provision", :cwd => @tempdir)
      expect(result.stdout).to include "==> default: Running provisioner: shell..."
      expect(result.stdout).to include "    default: hello docker!"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it "is DISTRIB_ID=#{os.capitalize} / DISTRIB_RELEASE=#{version} in lsb-release file" do
      result = run_command("vagrant ssh -c 'cat /etc/lsb-release'", :cwd => @tempdir)
      expect(result.stdout).to include "DISTRIB_ID=#{os.capitalize}"
      expect(result.stdout).to include "DISTRIB_RELEASE=#{version}"
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it "is running under #{arch} architecture" do
      result = run_command("vagrant ssh -c 'dpkg --print-architecture'", :cwd => @tempdir)
      expect(result.stdout).to match arch
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
      result2 = run_command("vagrant ssh -c 'uname --machine --processor --hardware-platform'", :cwd => @tempdir)
      if arch == 'amd64'
        expect(result2.stdout).to match 'x86_64 x86_64 x86_64'
      elsif arch == 'arm64'
        expect(result2.stdout).to match 'aarch64 aarch64 aarch64'
      else
        raise "unsupported architecture: #{arch}"
      end
      expect(result2.stderr).to match ""
      expect(result2.status.exitstatus).to eq 0
    end
    it 'can be stopped via `vagrant halt`' do
      result = run_command("vagrant halt", :cwd => @tempdir)
      expect(result.stdout).to include "==> default: Stopping container..."
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
    it 'can be destroyed via `vagrant destroy`' do
      result = run_command("vagrant destroy -f", :cwd => @tempdir)
      expect(result.stdout).to include "==> default: Deleting the container..."
      expect(result.stderr).to match ""
      expect(result.status.exitstatus).to eq 0
    end
  end
end
