require "#{File.dirname(__FILE__)}/spec_helper"

module FreeswitchApplicationsSpecHelper
  def freeswitch_command(app, pars = nil)    
    cmd = "sendmsg "
    cmd += "\ncall-command: execute"
    cmd += "\nexecute-app-name: #{app}"
    cmd += "\nexecute-app-arg: #{pars}" unless pars.blank?
    cmd += "\nevent-lock:true"
    cmd += "\n\n"
    cmd
  end
end

describe "how Freec calls Freeswitch applications" do
  include FreeswitchApplicationsSpecHelper
  before do
    class FreecForApplicationsSpec < Freec
      def post_init
        #ignored in this test        
      end
    end
    @freec = FreecForApplicationsSpec.new('')
    @freec.log.level = Logger::FATAL 
  end

  it "should execute the answer app when called the answer method" do
    @freec.should_receive(:send_data).with(freeswitch_command('answer'))
    @freec.answer
  end
  
  it "should execute the playback app when called the playback method" do
    @freec.should_receive(:send_data).with(freeswitch_command('playback', 'sounds/file.wav'))
    @freec.playback('sounds/file.wav')
  end

  it "should execute the phrase app with spell option when called the spell method" do
    @freec.should_receive(:send_data).with(freeswitch_command('phrase', 'spell,abcd'))
    @freec.spell('abcd')
  end

  it "should execute the bridge app when called the bridge method" do
    @freec.should_receive(:send_data).with(freeswitch_command('bridge', 'user/brian@10.0.1.2'))
    @freec.bridge('user/brian@10.0.1.2')
  end

  it "should pass all numbers passed to the bridge method as params of the bridge separated by comma (thus numbers are called simultaneously)" do
    @freec.should_receive(:send_data).with(freeswitch_command('bridge', 'user/brian@10.0.1.2,user/karl@10.0.1.2'))
    @freec.bridge(['user/brian@10.0.1.2', 'user/karl@10.0.1.2'])
  end

  it "should execute the record app when called the record method" do
    @freec.should_receive(:send_data).with(freeswitch_command('record', 'recordings/file.mp3 600'))
    @freec.record('recordings/file.mp3')
  end

  it "should set the time_limit_secs option send to the record method as the max length of the recording" do
    @freec.should_receive(:send_data).with(freeswitch_command('record', 'recordings/file.mp3 120'))
    @freec.record('recordings/file.mp3', :time_limit_secs => 120)
  end

  it "should execute the read app when called the input method" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '1 1 sounds/file.mp3 input 10000 #'))
    @freec.read('sounds/file.mp3')
  end

  it "should allow to pass the minimum and maximum digits to be read" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '2 5 sounds/file.mp3 input 10000 #'))
    @freec.read('sounds/file.mp3', :min => 2, :max => 5)
  end

  it "should allow to pass the timeout in seconds before the read apps before it times out" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '1 1 sounds/file.mp3 input 5000 #'))
    @freec.read('sounds/file.mp3', :timeout => 5)
  end

  it "should allow to pass the terminator for the read app" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '1 1 sounds/file.mp3 input 10000 *'))
    @freec.read('sounds/file.mp3', :terminators => '*')
  end

  it "should allow to pass the terminators as an array for the read app" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '1 1 sounds/file.mp3 input 10000 #,*'))
    @freec.read('sounds/file.mp3', :terminators => ['#', '*'])
  end

  it "should allow to specify the variable name the input is read by the read app" do
    @freec.should_receive(:send_data).with(freeswitch_command('read', '1 1 sounds/file.mp3 name 10000 #'))
    @freec.read('sounds/file.mp3', :variable => 'name')
  end
  
  it "should call the set app to set a variable" do
    @freec.should_receive(:send_data).with(freeswitch_command('set', 'name=value'))
    @freec.set_variable('name', 'value')
  end
  
  it "should call the hangup app when caled the hangup method" do
    @freec.should_receive(:send_data).with(freeswitch_command('hangup'))
    @freec.hangup_app
  end
    
end