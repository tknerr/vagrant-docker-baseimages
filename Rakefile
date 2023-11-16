
require 'rubygems/package'

ALL_PLATFORMS = {
  ubuntu: [ "14.04", "16.04", "18.04", "20.04", "22.04"]
}
TARGET_ARCHITECTURES = ['amd64', 'arm64']

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
      TARGET_ARCHITECTURES.each do |arch|
        import_multiarch_docker_image(os, version, arch)
        run_rspec("baseimage_spec", os, version, arch)
      end
    end
  end
end

desc "publish the docker base images"
task "publish:docker:base_images" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      publish_docker_image(os, version)
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
      TARGET_ARCHITECTURES.each do |arch|
        import_multiarch_docker_image(os, version, arch)
        run_rspec("basebox_spec", os, version, arch)
      end
    end
  end
end

desc "publish the vagrant baseboxes"
task "publish:vagrant:baseboxes" do
  selected_platforms.each_pair do |os, versions|
    versions.each do |version|
      publish_vagrant_basebox(os, version)
    end
  end
end

desc "clean output directories and destroy builders"
task "build:cleanup" do
  sh "git clean -ffdx"
  destroy_multiarch_docker_builder()
end

def build_docker_image(os, version)
  create_multiarch_docker_builder()
  sh "docker buildx build --no-cache --platform=#{docker_platform(TARGET_ARCHITECTURES)} -t #{docker_image_name(os, version)} #{dir(os, version)}"
end

def create_multiarch_docker_builder()
  sh "docker buildx rm --builder=baseimage-builder || true"
  sh "docker buildx create --name=baseimage-builder --platform=#{docker_platform(TARGET_ARCHITECTURES)} --use"
  sh "docker buildx inspect"
end
def use_multiarch_docker_builder()
  sh "docker buildx use --builder=baseimage-builder"
  sh "docker buildx inspect"
end
def destroy_multiarch_docker_builder()
  sh "docker buildx rm --builder=baseimage-builder || true"
end
def import_multiarch_docker_image(os, version, arch)
  use_multiarch_docker_builder()
  sh "docker rmi #{docker_image_name(os, version)} -f"
  sh "docker buildx build --load --platform=#{docker_platform([arch])} -t #{docker_image_name(os, version)} #{dir(os, version)}"
end

def publish_docker_image(os, version)
  use_multiarch_docker_builder()
  sh <<~SCRIPT
    set -e
    docker login
    docker buildx build --push --platform=#{docker_platform(TARGET_ARCHITECTURES)} -t #{docker_image_name(os, version)} #{dir(os, version)}
    docker logout
  SCRIPT
end

def publish_vagrant_basebox(os, version)
  desc = "A Vagrant-friendly docker baseimage for #{os.capitalize} #{version}. See https://github.com/tknerr/vagrant-docker-baseimages"
  # NOTE: we use architecture 'unknown' here so the same architecture independent basebox will be used
  sh "vagrant cloud publish --release --no-private --short-description='#{desc}' --version-description='#{desc}' --architecture='unknown' \
        #{vagrant_box_name(os, version)} 1.0.0 docker #{vagrant_box_path(os, version)}"
end

def build_vagrant_basebox(os, version)
  box = File.open("#{vagrant_box_path(os, version)}", 'wb')
  Gem::Package::TarWriter.new(box) do |tar|
    tar.add_file("metadata.json", 0644) do |f|
      # NOTE: we don't add architecture info here, so that the box remains architecture independent
      # see https://developer.hashicorp.com/vagrant/docs/boxes/format
      f.write <<~METADATA
        {
            "provider": "docker"
        }
      METADATA
    end
    tar.add_file("Vagrantfile", 0644) do |f|
      # NOTE: we don't add `create_args = '--platform=linux/amd64'` here, so that the Vagrantfile remains
      # architecture independent. The vagrant docker provider will choose the correct arch / docker image
      # to pull based on the host architecture (or can be overridden via DOCKER_DEFAULT_PLATFORM env var)
      # see https://developer.hashicorp.com/vagrant/docs/providers/docker/configuration
      f.write <<~VAGRANTFILE
        Vagrant.configure(2) do |config|
          config.vm.provider "docker" do |d|
            d.image = "#{docker_image_name(os, version)}"
            d.has_ssh = true
          end
        end
      VAGRANTFILE
    end
  end
end

def run_rspec(spec_name, os, version, arch)
  ENV['OS_UNDER_TEST'] = os.to_s
  ENV['VERSION_UNDER_TEST'] = version.to_s
  ENV['ARCH_UNDER_TEST'] = arch.to_s
  sh "rspec --format doc --color --tty \
            --format RspecJunitFormatter --out out/test-results/junit/#{spec_name}-#{os}-#{version}-#{arch}-junit-report.xml \
            --format html --out out/test-results/#{spec_name}-#{os}-#{version}-#{arch}-test-report.html \
            spec/#{spec_name}.rb"
end

def dir(os, version)
  "#{os}-#{version.delete('.')}"
end
def docker_image_name(os, version)
  "tknerr/baseimage-#{os}:#{version}"
end
def docker_platform(archs)
  archs.map {|arch| "linux/#{arch}"}.join(',')
end
def vagrant_box_name(os, version)
  "tknerr/baseimage-#{os}-#{version}"
end
def vagrant_box_path(os, version)
  "#{dir(os, version)}/baseimage-#{os}-#{version}.box"
end