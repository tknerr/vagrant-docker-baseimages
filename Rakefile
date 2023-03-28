
require 'rubygems/package'

ALL_PLATFORMS = {
  ubuntu: [ "14.04", "16.04", "18.04", "20.04", "22.04"]
}

def selected_platforms
  platform = ENV.fetch('PLATFORM', 'ubuntu-22.04').strip
  if platform == 'all'
    ALL_PLATFORMS
  else
    os, version = platform.split('-')
    {
      os.to_sym => version.nil? ? ALL_PLATFORMS[os.to_sym] : [ version ]
    }
  end
end

desc "build the docker base images"
task "build:docker:base_images" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      build_docker_image(os, version)
    end
  end
end

desc "test the docker base images"
task "test:docker:base_images" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      run_rspec("baseimage_spec", os, version)
    end
  end
end

desc "build the vagrant baseboxes"
task "build:vagrant:baseboxes" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      build_vagrant_basebox(os, version)
    end
  end
end

desc "test the vagrant baseboxes"
task "test:vagrant:baseboxes" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      run_rspec("basebox_spec", os, version)
    end
  end
end


def build_docker_image(os, version)
  image = "tknerr/baseimage-#{os}:#{version}"
  sh "docker rmi #{image} -f"
  sh "docker build --no-cache -t #{image} #{dir(os, version)}"
end

def build_vagrant_basebox(os, version)
  box = File.open("#{dir(os, version)}/baseimage-#{os}-#{version}.box","wb")
  Gem::Package::TarWriter.new(box) do |tar|
    tar.add_file("metadata.json", 0644) do |f|
      f.write <<~METADATA
        {
            "provider": "docker"
        }
      METADATA
    end
    tar.add_file("Vagrantfile", 0644) do |f|
      f.write <<~VAGRANTFILE
        Vagrant.configure(2) do |config|
          config.vm.provider "docker" do |d|
            d.image = "tknerr/baseimage-#{os}:#{version}"
            d.has_ssh = true
          end
        end
      VAGRANTFILE
    end
  end
end

def run_rspec(spec_name, os, version)
  ENV['OS_UNDER_TEST'] = os.to_s
  ENV['VERSION_UNDER_TEST'] = version.to_s
  sh "rspec --format doc --color --tty \
            --format RspecJunitFormatter --out out/test-results/junit/#{spec_name}-#{os}-#{version}-junit-report.xml \
            --format html --out out/test-results/#{spec_name}-#{os}-#{version}-test-report.html \
            spec/#{spec_name}.rb"
end

def dir(os, version)
  "#{os}-#{version.delete('.')}"
end
