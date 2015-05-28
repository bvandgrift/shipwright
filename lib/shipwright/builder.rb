module Shipwright
  class Builder

    BASE_VERSION   = '1.0.0'
    VERSION_FILE   = 'VERSION'
    DOCKERRUN      = 'Dockerrun.aws.json'
    COMMIT_MESSAGE = "new version %s built by Shipwright #{Shipwright::VERSION}"

    attr_accessor :path, :commit_message, :previous_version, :version

    def self.build(path)
      new(path).build
    end

    def self.bump
      Bump::Bump.run('patch', bundle: false, tag: false)
      Shipwright.info "Installed #{version} into #{VERSION_FILE}"
    end

    def self.init
      return if version

      Shipwright.info "Installing #{BASE_VERSION} into #{VERSION_FILE}"
      File.open(VERSION_FILE, 'wb') { |f| f.write BASE_VERSION }
    end

    def self.version
      Bump::Bump.version_from_version.tap { |v| return v.first if v }
    end

    def initialize(path)
      self.path = path
    end

    def build
      self.class.init
      Shipwright.info "Shipwright is building #{path} (at #{self.class.version})"

      bump_version

      build_image
      push_image

      generate_dockerrun
      generate_artifact
      update_ebconfig

      git_commit
      git_push

      Shipwright.info "VERSION #{version} built"
    end

    def bump_version
      self.class.bump
    end

    def build_image
      Shipwright.info "Building image with tag #{docker_tag}"
      self.image = Docker::Image.build_from_dir(path, 'tag' => docker_tag)
    end

    def push_image
      Shipwright.info "Pushing image to #{docker_tag}"
      image.push
    end

    def generate_dockerrun
      Shipwright.info "Generating Dockerrun"
      Shipwright::ElasticBeanstalk.generate_dockerrun
    end

    def generate_artifact
      Shipwright.info "Generating artifact"
      Shipwright::ElasticBeanstalk.generate_artifact
    end

    def update_ebconfig
      Shipwright.info "Updating .elasticbeanstalk/config.yml"
      Shipwright::ElasticBeanstalk.update_config
    end

    def git_commit
      Shipwright.info "Commiting to git"
      git.add all: true
      git.commit COMMIT_MESSAGE % version
      git.add_tag git_tag
    end

    def git_push
      Shipwright.info "Pushing to git"
      git.push
    end

    def git_tag
      "build-#{version}"
    end

    def docker_tag
      "#{shipyard}/#{application}:#{version}"
    end

    def version
      @version ||= self.class.version
    end

    def shipyard
      ENV.fetch('SHIPYARD') { raise "set SHIPYARD= to your docker host/scope" }
    end

    def application
      File.basename Dir.pwd
    end

    protected

    attr_accessor :image

    def git
      @git ||= Git.open(Dir.pwd)
    end

  end
end