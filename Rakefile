
require './spec/helpers'
require 'rubygems/package'

include Helpers

PLATFORMS = {
  ubuntu: ["12.04", "14.04", "16.04", "18.04"]
}

desc "build the docker base images"
task :build do
  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|
      build_docker_image(platform, version)
    end
  end
end

desc "generate the vagrant .box files"
task :generate do
  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|
      build_vagrant_basebox(platform, version)
    end
  end
end

desc "run integration tests"
task :test do
  sh "rspec --format doc --color"
end


def build_docker_image(platform, version)
  image = "tknerr/baseimage-#{platform}:#{version}"
  sh "docker build -t #{image} #{dir(platform, version)}"
end

def build_vagrant_basebox(platform, version)
  box = File.open("#{dir(platform, version)}/baseimage-#{platform}-#{version}.box","wb")
  Gem::Package::TarWriter.new(box) do |tar|
    tar.add_file("metadata.json", 0644) { |f| f.write metadata_json }
    tar.add_file("Vagrantfile", 0644) { |f| f.write minimal_vagrantfile(platform, version) }
  end
end

def dir(platform, version)
  "#{platform}-#{version.delete('.')}"
end
