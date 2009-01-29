require 'logger'

class FreecLogger < Logger
    def format_message(severity, timestamp, progname, msg)  #:nodoc:
      "#{timestamp.strftime("%Y-%m-%d %H:%M:%S")} #{severity} #{msg}\n"
    end
    
    # Prints the message with twenty #'s before and after it.
    def highlighted_info(message)
      info("#{'#'*20} #{message} #{'#'*20}")
    end
end
