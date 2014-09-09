require 'fileutils'

namespace :starter do

  task :load do
    set(:dockerfile_helpers, {
      install_ruby_200: lambda {
        dfi :run, 'installers/install_ruby.sh', 'http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p481.tar.gz'
      },
      install_haproxy_153: lambda {
        dfi :run, 'installers/install_haproxy.sh', 'http://www.haproxy.org/download/1.5/src/haproxy-1.5.3.tar.gz'
      }
    }.merge(fetch(:dockerfile_helpers)))

    set(:services, {
      haproxy: "haproxy -f /root/conf/haproxy.conf",

      haproxy_config_updater: "/root/bin/pyconfd -t /root/conf/haproxy.conf.tmpl -s haproxy -k USR1 -a $APP_KEY",

      heartbeat: "/root/bin/heartbeat -a $APP_KEY",

      mongodb: "/usr/bin/mongod --bind_ip 0.0.0.0 --logpath /var/log/mongodb.log",

      nginx: "nginx",

      unicorn: "cd /app && bundle exec unicorn -c /root/conf/unicorn.rb",

      pyrep: "/root/bin/pyrep -t #{fetch(:boxchief_app_token)}"

    }.merge(fetch(:services)))
  end


  namespace :install do
    desc "Install files to project"
    task :all do

      files_path = Cloudpad::Starter.files_path
      puts "Installing starter files from #{files_path}.".yellow
      # TODO: get list of all files in dir and copy if changed
      sh "cp -auv #{files_path}/* #{root_path}"
    end

    task :manifests do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/manifests #{root_path}"
    end
    task :context do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context #{root_path}"
    end
    task :bin do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context/bin #{root_path}/context"
    end
    task :conf do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context/conf #{root_path}/context"
    end
    task :installers do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context/installers #{root_path}/context"
    end
    task :keys do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context/keys #{root_path}/context"
    end
    task :services do
      files_path = Cloudpad::Starter.files_path
      sh "cp -auv #{files_path}/context/services #{root_path}/context"
    end

  end

end

after 'docker:load', 'starter:load'
