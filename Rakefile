
require './spec/helpers'
require 'rubygems/package'

include Helpers

PLATFORMS = {
  ubuntu: ["12.04", "14.04", "16.04", "18.04"]
}

desc "build the docker base images"
task "build:docker:base_images" do
  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|
      build_docker_image(platform, version)
    end
  end
end

desc "test the docker base images"
task "test:docker:base_images" do
  run_rspec("baseimage_spec")
end

desc "build the vagrant baseboxes"
task "build:vagrant:baseboxes" do
  PLATFORMS.each_pair do |platform, versions|
    versions.each do |version|
      build_vagrant_basebox(platform, version)
    end
  end
end

desc "test the vagrant baseboxes"
task "test:vagrant:baseboxes" do
  run_rspec("basebox_spec")
end


def build_docker_image(platform, version)
  image = "tknerr/baseimage-#{platform}:#{version}"
  sh "docker rmi #{image} -f"
  sh "docker build --no-cache -t #{image} #{dir(platform, version)}"
end

def build_vagrant_basebox(platform, version)
  box = File.open("#{dir(platform, version)}/baseimage-#{platform}-#{version}.box","wb")
  Gem::Package::TarWriter.new(box) do |tar|
    tar.add_file("metadata.json", 0644) { |f| f.write metadata_json }
    tar.add_file("Vagrantfile", 0644) { |f| f.write minimal_vagrantfile(platform, version) }
  end
end

def run_rspec(spec_name)
  sh "rspec --format doc --color --tty \
            --format RspecJunitFormatter --out out/test-results/junit/#{spec_name}-junit-report.xml \
            --format html --out out/test-results/#{spec_name}-test-report.html \
            spec/#{spec_name}.rb"
end

def dir(platform, version)
  "#{platform}-#{version.delete('.')}"
end

