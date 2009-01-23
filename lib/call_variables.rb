module CallVariables

  def sip_from_user
    call_vars[:variable_sip_from_user]
  end
  
  def sip_to_user
    call_vars[:variable_sip_to_user]    
  end
  
  def channel_destination_number
    call_vars[:channel_destination_number]    
  end

end