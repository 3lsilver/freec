require "#{File.dirname(__FILE__)}/spec_helper"


describe "how Freec makes accessible call variables" do

  before do
    class FreecForCallsVarSpec < Freec
      def post_init
        #changed for this spec
        log.level = Logger::FATAL 
        @response = SAMPLE_CALL_VARIABLES
        parse_response
      end
    end
    @freec = FreecForCallsVarSpec.new('')
  end
  
  it "should make the value of the sip_from_user variable available as a method" do
    @freec.sip_from_user.should == '1001'
  end

  it "should make the value of the sip_to_user variable available as a method" do
    @freec.sip_to_user.should == '886'
  end

  it "should make the value of the channel_destination_number variable available as a method" do
    @freec.channel_destination_number.should == '886'
  end


end