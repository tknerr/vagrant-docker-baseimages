require 'spec_helper'

describe 'base boxes for the docker baseimages' do

  PLATFORMS = {
    ubuntu: ["12.04", "14.04", "16.04", "18.04"]
  }

  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|

      before(:all) do
        @tempdir = Dir.mktmpdir
        write_config @tempdir, vagrantfile_referencing_local_basebox(platform, version)
      end

      after(:all) do
        FileUtils.rm_rf @tempdir
      end

      describe "tknerr/baseimage-#{platform}-#{version}" do
        it 'can be imported via `vagrant box add`' do
          basebox_name = "tknerr/baseimage-#{platform}-#{version}"
          basebox_file = "#{platform}-#{version.delete('.')}/baseimage-#{platform}-#{version}.box"
          result = run_command("vagrant box add --name #{basebox_name} --provider docker --force #{basebox_file}")
          expect(result.stdout).to include "==> box: Box file was not detected as metadata. Adding it directly..."
          expect(result.stdout).to include "==> box: Successfully added box '#{basebox_name}' (v0) for 'docker'!"
          expect(result.status.exitstatus).to eq 0
        end
        it 'comes up via `vagrant up --provider docker`' do
          result = run_command("vagrant up --provider docker", :cwd => @tempdir)
          expect(result.stdout).to include "==> default: Machine booted and ready!"
          expect(result.stderr).to match ""
          expect(result.status.exitstatus).to eq 0
        end
        it 'can be destroyed via `vagrant destroy`' do
          result = run_command("vagrant destroy -f", :cwd => @tempdir)
          expect(result.stdout).to include "==> default: Deleting the container..."
          # destroying containers does not work on circleci
          unless ENV['CIRCLECI']
            expect(result.stderr).to match ""
            expect(result.status.exitstatus).to eq 0
          end
        end
      end

    end
  end
end
