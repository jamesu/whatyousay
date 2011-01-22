require 'spec_helper'

describe BipParser do
  before do
    @collection = LogCollection.new
    @parser = BipParser.new(@collection)
  end
  
  it "should parse messages" do
    bip_data = File.open("tests/fixtures/bip.log") {|f| f.read}
    @data = StringIO.new(bip_data)
    @data.each_line do |line|
      event = @parser.parse_line(line)
      event.should_not == nil
      event[:sender].should_not == nil
    end
  end
  
  it "should accept messages" do
    event = @parser.parse_line("01-04-2010 11:41:28 < woot!~47e0bd37@someclient1: hello folks")
    event[:type].should == :message
    event[:content].should == "hello folks"
    event[:occurred].to_s.should == "Thu Apr 01 11:41:28 UTC 2010"
    event[:sender][:ident].should == "~47e0bd37"
    event[:sender][:host].should == "someclient1"
    event[:sender][:name].should == "woot"
    
    event = @parser.parse_line("01-04-2010 12:26:44 > Myself: haha")
    event[:type].should == :message
    event[:content].should == "haha"
    event[:occurred].to_s.should == "Thu Apr 01 12:26:44 UTC 2010"
    event[:sender][:ident].should == "Myself"
    event[:sender][:host].should == nil
    event[:sender][:name].should == "Myself"
  end
  
  it "should accept quit messages" do
    event = @parser.parse_line("01-04-2010 00:04:49 -!- LongWind!~long@some.other.server has quit [Quit: Leaving]")
    event[:type].should == :userDisconnected
    event[:content].should == "has quit [Quit: Leaving]"
    event[:occurred].to_s.should == "Thu Apr 01 00:04:49 UTC 2010"
    event[:sender][:ident].should == "~long"
    event[:sender][:host].should == "some.other.server"
    event[:sender][:name].should == "LongWind"
    
    event = @parser.parse_line("01-04-2010 11:08:12 -!- SoGot!|SoGot!~chatzilla@some.server.net has quit [Client closed connection]")
    event[:type].should == :userDisconnected
    event[:content].should == "has quit [Client closed connection]"
    event[:occurred].to_s.should == "Thu Apr 01 11:08:12 UTC 2010"
    event[:sender][:ident].should == "|SoGot!~chatzilla"
    event[:sender][:host].should == "some.server.net"
    event[:sender][:name].should == "SoGot"
  end
  
  it "should accept join messages" do
    event = @parser.parse_line("01-04-2010 01:14:48 -!- wooter!~wooter@pool-party.net has joined #letstalk")
    event[:type].should == :userAvailable
    event[:content].should == "has joined #letstalk"
    event[:occurred].to_s.should == "Thu Apr 01 01:14:48 UTC 2010"
    event[:sender][:ident].should == "~wooter"
    event[:sender][:host].should == "pool-party.net"
    event[:sender][:name].should == "wooter"
  end
end
