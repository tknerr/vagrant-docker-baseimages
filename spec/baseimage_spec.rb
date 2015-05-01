require 'spec_helper'

describe 'vagrant-friendly docker baseimages' do

  PLATFORMS = {
    ubuntu: ["12.04", "14.04"]
  }

  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|

      describe "#{platform}-#{version}" do
        around(:each) do |example|
          Dir.mktmpdir do |dir|
            @tempdir = dir
            write_vagrantfile_with_provisioner(@tempdir, platform, version)
            example.run
          end
        end
        it 'is not created when I run `vagrant status`' do
          cmd = Mixlib::ShellOut.new("vagrant status", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "not created (docker)"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'comes up when I run `vagrant up --no-provision`' do
          cmd = Mixlib::ShellOut.new("vagrant up --no-provision", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "==> default: Machine booted and ready!"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'is now shown as running when I run `vagrant status` again' do
          cmd = Mixlib::ShellOut.new("vagrant status", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "running (docker)"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'accepts remote ssh commands via `vagrant ssh -c`' do
          cmd = Mixlib::ShellOut.new("vagrant ssh -c pwd", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "/home/vagrant"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'can be provisioned with a shell script via `vagrant provision`' do
          cmd = Mixlib::ShellOut.new("vagrant provision", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "==> default: Running provisioner: shell..."
          expect(result.stdout).to include "==> default: hello docker!"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'can be stopped via `vagrant halt`' do
          cmd = Mixlib::ShellOut.new("vagrant halt", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "==> default: Stopping container..."
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'can be destroyed via `vagrant destroy`' do
          cmd = Mixlib::ShellOut.new("vagrant destroy -f", :cwd => @tempdir)
          result = cmd.run_command
          expect(result.stdout).to include "==> default: Deleting the container..."
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
      end

    end
  end
end
