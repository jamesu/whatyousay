require 'spec_helper'

LOG_OPEN = "--- Log opened Wed Jan 06 13:15:17 2010"

describe IrciiParser do
  before do
    @collection = LogCollection.new
    @parser = IrciiParser.new(@collection)
  end
  
  it "should parse messages" do
    ircii_data = File.open("spec/fixtures/ircii.log") {|f| f.read}
    @data = StringIO.new(ircii_data)
    events = []
    @data.each_line do |line|
      events << @parser.parse_line(line)
    end
    events.compact.length.should == 28
  end
  
  it "should accept messages" do
    event = @parser.parse_line(LOG_OPEN)
    event.should == nil
    event = @parser.parse_line("16:19 < Myself> yo woot")
    event[:type].should == :message
    event[:content].should == "yo woot"
    event[:occurred].to_s.should == "Wed Jan 06 16:19:00 UTC 2010"
    event[:sender][:ident].should == "Myself"
    event[:sender][:host].should == nil
    event[:sender][:name].should == "Myself"
    
    event = @parser.parse_line("16:23 < woot> lol why is that? what did you expect?")
    event[:type].should == :message
    event[:content].should == "lol why is that? what did you expect?"
    event[:occurred].to_s.should == "Wed Jan 06 16:23:00 UTC 2010"
    event[:sender][:ident].should == "woot"
    event[:sender][:host].should == nil
    event[:sender][:name].should == "woot"
  end
  
  it "should change the date according to the input" do
    @parser.parse_line("--- Log opened Tue Jan 06 13:15:17 2009").should == nil
    event = @parser.parse_line("16:19 < Myself> yo woot")
    event[:occurred].to_s.should == "Tue Jan 06 16:19:00 UTC 2009"
    
    @parser.parse_line("--- Day changed Thu Jan 07 2010").should == nil
    event = @parser.parse_line("16:23 < woot> lol why is that? what did you expect?")
    event[:occurred].to_s.should == "Thu Jan 07 16:23:00 UTC 2010"
    
    @parser.parse_line("--- Log closed Wed Feb 24 21:15:50 2011").should == nil
    event = @parser.parse_line("16:23 < woot> gonna go back to the future!")
    event[:occurred].to_s.should == "Thu Feb 24 16:23:00 UTC 2011"
  end
  
  it "should accept quit messages" do
    event = @parser.parse_line(LOG_OPEN)
    event = @parser.parse_line("15:01 -!- Sick [~Sick@192.168.0.1] has quit [Ping timeout]")
    event[:type].should == :userDisconnected
    event[:content].should == "has quit [Ping timeout]"
    event[:occurred].to_s.should == "Wed Jan 06 15:01:00 UTC 2010"
    event[:sender][:ident].should == "~Sick"
    event[:sender][:host].should == "192.168.0.1"
    event[:sender][:name].should == "Sick"
  end
  
  it "should accept join messages" do
    event = @parser.parse_line(LOG_OPEN)
    event = @parser.parse_line("15:16 -!- Sick [~Sick@192.168.0.1] has joined #letstalk")
    event[:type].should == :userAvailable
    event[:content].should == "has joined #letstalk"
    event[:occurred].to_s.should == "Wed Jan 06 15:16:00 UTC 2010"
    event[:sender][:ident].should == "~Sick"
    event[:sender][:host].should == "192.168.0.1"
    event[:sender][:name].should == "Sick"
  end
end
