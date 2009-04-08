module FreeswitchApplications
  
  # Answers the call.
  def answer
    execute_app('answer')
  end

  # Plays the file in file_name
  # file_name is either an absolute path or path relative 
  # to the sound_prefix variable set in Freeswitch's vars.xml configuration file.
  def playback(file_name)
    execute_app('playback', file_name)
  end

  # Spells the string
  def spell(string)
    execute_app('phrase', "spell,#{string}")
  end
  
  # Bridges the call to the given number or numbers (this param can be a number or an array of numbers).
  def bridge(number_or_numbers, options = {})
    number_or_numbers = number_or_numbers.join(",") if number_or_numbers.is_a?(Array)
    execute_app("bridge", "#{number_or_numbers}")
  end
  
  # Transfers the call to the given extension
  def transfer(extension)
    execute_app("transfer", "#{extension}")
  end
  
  # Records the call to a file with the given file_name
  # file_name is either an absolute path or path relative 
  # to the sound_prefix variable set in Freeswitch's vars.xml configuration file.
  #
  # Options:
  # * <tt>:time_limit_secs</tt> overrides the default timeout, which is 600 seconds
  def record(file_name, options = {})
    options = {:time_limit_secs => 600}.merge(options) #no reverse_merge, no fun :-)
    execute_app("record", "#{file_name} #{options[:time_limit_secs]}")
  end
  
  # Plays the file in file_name and reads input (key presses) from the user.
  #
  # Options:
  # * <tt>:terminators</tt> option to set a different terminator or terminators (defaults to '#')
  # * <tt>:variable</tt> to set the variable where the results is put (defaults to call_vars[:input])
  # * <tt>:timeout</tt> to override the default timeout value (which is 10 seconds)
  # * <tt>:min and :max</tt> options to override the default maximum and minimum of characters that will be read (both default to 1)
  def read(file_name, options = {})
    options[:terminators] = [options[:terminators]] if options[:terminators].is_a?(String)
    options = {:timeout => 10, :variable => 'input', :min => 1, :max => 1, :terminators => ['#']}.merge(options)
    execute_app("read", "#{options[:min]} #{options[:max]} #{file_name} #{options[:variable]} #{options[:timeout] * 1000} #{options[:terminators].join(',')}")
  end
  
  # Starts recording the call in file in file_name
  #
  def start_recording(file_name)
    execute_app('record_session', file_name)
  end

  # Stops recording the call in file in file_name
  #  
  def stop_recording(file_name)
    execute_app('stop_record_session', file_name)
  end
  
  # Sets a variable with the give name to the given value.
  def set_variable(name, value)
    execute_app('set', "#{name}=#{value}")
  end

  # Hangs up the call.
  def hangup_app
    execute_app('hangup')
  end  
  
  # Executes an app using the sendmsg command of Freeswitch.
  # Use this if there is no method for the application you want to run.
  #
  # Params:
  # * <tt>app</tt> is the application name
  # * <tt>pars</tt> is a string of arguments of the app
  # * <tt>lock</tt> can be set to false so Freeswitch won't wait for this app to finish before running the next one
  def execute_app(app, pars = '', lock = true)
    @last_app_executed = app
    cmd = "sendmsg #{@unique_id}"
    cmd << "\ncall-command: execute"
    cmd << "\nexecute-app-name: #{app}"
    cmd << "\nexecute-app-arg: #{pars}" unless pars.blank?
    cmd << "\nevent-lock:#{lock}"
    send_response cmd
  end  
end