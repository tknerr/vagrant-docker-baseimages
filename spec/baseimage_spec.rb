require 'spec_helper'

describe 'vagrant-friendly docker baseimages' do

  describe 'ubuntu-12.04' do

    around(:each) do |example|
      Dir.mktmpdir do |dir|
        @tempdir = dir
        write_vagrantfile_with_provisioner(@tempdir, "ubuntu", "12.04")
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
