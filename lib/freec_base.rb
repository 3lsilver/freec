require 'rubygems'
require 'eventmachine'
require 'extlib'
require 'uri'

require "freeswitch_applications"
require "call_variables"
require 'freec_logger'

class Freec < EventMachine::Connection
  include FreeswitchApplications
  include CallVariables

  attr_reader :call_vars, :log
  
  def initialize(*args) #:nodoc:
    super
    @log = FreecLogger.new(['development', 'test'].include?(ENVIRONMENT) ? STDOUT : @@log_file)
    connect_to_database
  end
  
  def post_init #:nodoc:
    send_response "connect"
  end
  
  def receive_data(data) #:nodoc:
    read_response(data)
    return unless response_complete?
    return unless subscribe_to_events_if_not_subscribed
    parse_response
    if last_event_dtmf? && respond_to?(:on_dtmf)
      callback(:on_dtmf, call_vars[:dtmf_digit])
    elsif waiting_for_this_response? && reset_wait_for || execute_completed?
      reload_application_code
      hangup unless callback(:step)
    end
  end
  
  def wait_for(key, value)
    @waiting_for_key = key && key.to_sym
    @waiting_for_value = value
  end

  def reset_wait_for
    wait_for(nil, nil)
    true 
  end  

  #Hangs up the call and closes the connection to Freeswitch.
  def hangup
    hangup_app
    close_session
  end
  
  def unbind  #:nodoc:
    callback(:on_hangup) if respond_to?(:on_hangup)
  end
  
  def execute_completed?
    (channel_execute_complete? || channel_destroyed_after_bridge?) &&
    call_vars[:unique_id] == @unique_id
  end
  
private

  def channel_execute_complete?
    complete =  call_vars[:content_type] == 'text/event-plain' && 
                call_vars[:event_name] == 'CHANNEL_EXECUTE_COMPLETE' &&
                @last_app_executed == call_vars[:application]
    @last_app_executed = nil if complete
    complete
  end
  
  def channel_destroyed_after_bridge?
    call_vars[:application] == 'bridge' && call_vars[:event_name] == 'CHANNEL_DESTROY'
  end

  def callback(callback_name, *args)
    send(callback_name, *args) if respond_to?(callback_name)
  rescue StandardError => e
    log.error e.message
    e.backtrace.each {|trace_line| log.error(trace_line)}    
  end

  def reload_application_code
    return unless ENVIRONMENT == 'development'
    load($0)
    lib_dir = "#{ROOT}/lib"
    return unless File.exist?(lib_dir)
    Dir.open(lib_dir).each do |file|      
      full_file_name = File.join(lib_dir, file)
      next unless File.file?(full_file_name)
      load(full_file_name)
    end
  end

  def read_response(data)
    @response ||= ''
    @response += data
  end
  
  def response_complete?
    @response[-2..-1] == "\n\n"    
  end
  
  def subscribe_to_events_if_not_subscribed
    return true if @subscribed_to_events
    send_response 'myevents'
    @subscribed_to_events = true
    wait_for(:content_type, 'command/reply')
    false
  end
      
  def waiting_for_this_response?
    @waiting_for_key && @waiting_for_value && call_vars[@waiting_for_key] == @waiting_for_value
  end
  
  def last_event_dtmf?
    call_vars[:content_type] == 'text/event-plain' && call_vars[:event_name] == 'DTMF' && call_vars[:unique_id] == @unique_id
  end
    
  def close_session
    send_response "exit"
    close_connection_after_writing      
  end
      
  def send_response(data)
    log.debug "Sent: #{data}"
    send_data("#{data}\n\n")
  end
    
  def parse_response
    hash = {}
    @response.split("\n").each do |line|
      k,v = line.split(/\s*:\s*/)
      hash[k.strip.gsub('-', '_').downcase.to_sym] = URI.unescape(v).strip if k && v
    end    
    @call_vars ||= {}
    call_vars.merge!(hash)
    @unique_id ||= call_vars[:unique_id]
    raise call_vars[:reply_text] if call_vars[:reply_text] =~ /^-ERR/
    log.debug "Received:"
    log.debug "Session ID\tContent-type\tApplication\tEvent name"
    log.debug "#{object_id}\t#{call_vars[:content_type]}\t#{call_vars[:application]}\t#{call_vars[:event_name]}"
    @response = ''
  end
  
  def connect_to_database
    return unless @@config['database'] && @@config['database'][ENVIRONMENT]
    require 'active_record'
    ActiveRecord::Base.establish_connection(@@config['database'][ENVIRONMENT])
  end  
  
end