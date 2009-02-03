require "#{File.dirname(__FILE__)}/spec_helper"

# http://wiki.freeswitch.org/wiki/Channel_Variables#group_confirm_file


class FreecForSpec < Freec
  def initialize
    super
    log.level = Logger::FATAL 
  end
  def send_data(data)
    #emptied for this spec
  end
  def on_dtmf(digit)    
  end
  def on_external_hangup
  end
end


describe "Freec's post_init hook" do

  before do
    @freec = FreecForSpec.new('')
  end

  it "should send the 'connect' string in the post_init hook (which is called after connection is established)" do
    @freec.should_receive(:send_data).with("connect\n\n")
    @freec.post_init
  end

end

describe "Freec's receive_data hook" do
  before do
    @freec = FreecForSpec.new('')
  end
    
  it "should only stuff data in the response buffer if doesn't end with two new line characters" do
    @freec.receive_data('hey')
    @freec.send(:response_complete?).should be_false
    @freec.instance_variable_get(:@response).should == 'hey'
  end

  it "should only recognize the response as complete its data ends with two new line characters" do
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
    @freec.send(:response_complete?).should be_true
    @freec.instance_variable_get(:@response).should == SAMPLE_CALL_VARIABLES
  end
  
  it "should subscribe to events" do
    # @freec.should_receive(:send_data).with("event plain CHANNEL_CREATE CHANNEL_DESTROY CHANNEL_EXECUTE CHANNEL_EXECUTE_COMPLETE DTMF\n\n")
    @freec.should_receive(:send_data).with("myevents\n\n")
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
  end

  it "should wait for command/reply in the content-type of the response after subscribing to events" do
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
    @freec.send(:parse_response)    
    @freec.send(:waiting_for_this_response?).should be_true
  end

  it "should set the subscribed_to_events variable to true after subscribing to events to avoid subscribign again" do
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
    @freec.instance_variable_get(:@subscribed_to_events).should be_true
  end

  it "should read unique id from response" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
    @freec.instance_variable_get(:@unique_id).should == '40117b0a-186e-11dd-bbcd-7b74b6b4d31e'
  end

  it "should parse variables from response" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.receive_data(SAMPLE_CALL_VARIABLES)
    @freec.call_vars[:channel_username].should == '1001'
    @freec.call_vars[:caller_context].should == 'default'
    @freec.call_vars[:variable_sip_user_agent].should == 'snom300/7.1.30'
  end
  
  it "should call the on_dtmf callback if defined and last event was dtmf" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.should_receive(:on_dtmf).with('1')
    @freec.receive_data("Event-Name: DTMF\nDTMF-Digit: 1\n#{SAMPLE_CALL_VARIABLES}".sub('command/reply', 'text/event-plain'))
  end

  it "should not call the on_dtmf callback if not defined even if last event was dtmf" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.should_receive(:respond_to?).with(:on_dtmf).and_return(false)
    @freec.should_receive(:on_dtmf).with('1').never
    @freec.receive_data("Event-Name: DTMF\nDTMF-Digit: 1\n#{SAMPLE_CALL_VARIABLES}".sub('command/reply', 'text/event-plain'))
  end
  
  it "should call the step callback if response says event has been completed" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.should_receive(:step).and_return(true)
    @freec.receive_data("Event-Name: CHANNEL_EXECUTE_COMPLETE\n\n#{SAMPLE_CALL_VARIABLES}".sub('command/reply', 'text/event-plain'))    
  end

  it "should hangup the call, send exit command to Freeswitch and disconnect from it when step callback returns nil" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.should_receive(:step).and_return(nil)
    @freec.should_receive(:execute_app).with('hangup')
    @freec.should_receive(:send_data).with("exit\n\n")
    @freec.should_receive(:close_connection_after_writing)
    @freec.receive_data("Event-Name: CHANNEL_EXECUTE_COMPLETE\n\n#{SAMPLE_CALL_VARIABLES}".sub('command/reply', 'text/event-plain'))    
  end

end

describe "Freec's callback handling" do
  
  before do
    @freec = FreecForSpec.new('')
  end
  
  it "should catch and log any exception occured in a callback" do
    @freec.should_receive(:callback_name).and_raise(RuntimeError)
    @freec.log.should_receive(:error).with('RuntimeError')
    @freec.log.should_receive(:error).at_least(1).times #backtrace
    lambda { @freec.send(:callback, :callback_name) }.should_not raise_error(Exception)
  end

end

describe "Freec's custom waiting conditions" do

  before do
    @freec = FreecForSpec.new('')
    @freec.wait_for(:content_type, 'command/reply')
    @freec.send(:read_response, SAMPLE_CALL_VARIABLES)
    @freec.send(:parse_response)
  end
  
  it "should return true from waiting_for_this_response? when the conditions for the response are met" do
    @freec.send(:waiting_for_this_response?).should be_true
  end

  it "should return false from waiting_for_this_response? when the conditions for the response are not met" do
    @freec.wait_for(:content_type, 'text/event-plain')
    @freec.send(:read_response, SAMPLE_CALL_VARIABLES)
    @freec.send(:parse_response)
    @freec.send(:waiting_for_this_response?).should be_false
  end

  it "should reset the waiting conditions after they have been met" do
    @freec.instance_variable_set(:@subscribed_to_events, true)
    @freec.wait_for(:event_name, 'CHANNEL_EXECUTE')
    @freec.should_receive(:step).and_return(true)
    @freec.receive_data("Event-Name: CHANNEL_EXECUTE\n\n#{SAMPLE_CALL_VARIABLES}".sub('command/reply', 'text/event-plain'))
    @freec.send(:waiting_for_this_response?).should be_nil
  end

end

describe "Freec's unbind handler" do

  before do
    @freec = FreecForSpec.new('')
  end

  it "should call the on_hangup callback if defined" do
    @freec.should_receive(:on_hangup)
    @freec.unbind
  end

  it "should not call the on_hangup callback if not defined" do
    @freec.should_receive(:respond_to?).with(:on_hangup).and_return(false)
    @freec.should_receive(:on_hangup).never
    @freec.unbind    
  end

end
