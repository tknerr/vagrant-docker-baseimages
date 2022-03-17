require 'spec_helper'

describe 'vagrant-friendly docker baseimages' do

  PLATFORMS = {
    ubuntu: ["14.04", "16.04", "18.04"]
  }

  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|

      before(:all) do
        @tempdir = Dir.mktmpdir
        write_config @tempdir, vagrantfile_with_provisioner(platform, version)
        ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
      end

      after(:all) do
        FileUtils.rm_rf @tempdir
      end

      describe "#{platform}-#{version}" do
        it 'is not created when I run `vagrant status`' do
          result = run_command("vagrant status", :cwd => @tempdir)
          expect(result.stdout).to include "not created (docker)"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'comes up when I run `vagrant up --no-provision`' do
          result = run_command("vagrant up --no-provision", :cwd => @tempdir)
          expect(result.stdout).to include "Image: tknerr/baseimage-#{platform}:#{version}"
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
  end
end
