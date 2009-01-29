module CallVariables

  # Value of the variable_sip_from_user variable
  # This is the callee username/number
  def sip_from_user
    call_vars[:variable_sip_from_user]
  end

  # Value of the variable_sip_to_user variable
  # This is the called username/number  
  def sip_to_user
    call_vars[:variable_sip_to_user]    
  end

  # Value of the channel_destination_number variable
  # This is the extension this call was routed to in Freeswitch
  def channel_destination_number
    call_vars[:channel_destination_number]    
  end

end