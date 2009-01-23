lib_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "freec_base"

require 'fileutils'
require 'daemons/daemonize'
include Daemonize

def file_name
  $0.sub(/\.[^\.]*$/, '')  
end

def class_name
  file_name.split('_').map{|w| w.capitalize}.join
end

def log_dir
  "#{ROOT}/log"
end

def create_log_dir
  FileUtils.mkdir_p(log_dir)  
end

def log_file
  @@log_file ||= "#{log_dir}/#{file_name}.log"
end

def pid_file
  "#{log_dir}/#{file_name}.pid"
end

def load_config
  if File.exist?(configuration_file)
    @@config = YAML.load_file(configuration_file)
  else
    @@config = {}
  end
  @@config['listen_port'] ||= '8084' 
end

def configuration_file
  "#{ROOT}/config/config.yml"
end

unless defined?(TEST)
  at_exit do
    ROOT = File.expand_path(File.dirname($0))
    ENVIRONMENT = ARGV[0] == '-d' ? 'production' : 'development'
    create_log_dir
    load_config
    if ARGV[0] == '-d'
      puts 'Daemonizing...'
      daemonize(log_file)
    end
    open(pid_file, "w") {|f| f.write(Process.pid) }
    EventMachine::run do
      EventMachine::start_server '0.0.0.0', @@config['listen_port'].to_i, Kernel.const_get(class_name)
      puts "Listening on port #{@@config['listen_port']}"
    end
  end
end