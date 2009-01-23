module FreeswitchApplications
  
  def answer
    execute_app('answer')
  end
  
  def playback(file_name)
    execute_app('playback', file_name)
  end
  
  def bridge(number_or_numbers, options = {})
    number_or_numbers = number_or_numbers.join(",") if number_or_numbers.is_a?(Array)
    execute_app("bridge", "#{number_or_numbers}")
  end
  
  def record(file_name, options = {})
    options = {:time_limit_secs => 600}.merge(options) #no reverse_merge, no fun :-)
    execute_app("record", "#{file_name} #{options[:time_limit_secs]}")
  end
  
  def read(file_name, options = {})
    options[:terminators] = [options[:terminators]] if options[:terminators].is_a?(String)
    options = {:timeout => 10, :variable => 'input', :min => 1, :max => 1, :terminators => ['#']}.merge(options)
    execute_app("read", "#{options[:min]} #{options[:max]} #{file_name} #{options[:variable]} #{options[:timeout] * 1000} #{options[:terminators].join(',')}")
  end
  
  def set_variable(name, value)
    execute_app('set', "#{name}=#{value}")
  end

  def hangup_app
    execute_app('hangup')
  end  
  
  def execute_app(app, pars = '')
    cmd = "sendmsg #{@unique_id}"
    cmd << "\ncall-command: execute"
    cmd << "\nexecute-app-name: #{app}"
    cmd << "\nexecute-app-arg: #{pars}" unless pars.blank?
    cmd << "\nevent-lock:true"
    send_response cmd
  end  
end