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
      end

    end
  end
end
