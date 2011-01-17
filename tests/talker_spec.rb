require 'spec_helper'

describe TalkerParser do
  before do
    @collection = LogCollection.new
    @parser = TalkerParser.new(@collection)
  end
  
  it "should parse messages" do
    talker_data = File.open("tests/fixtures/talker.html") {|f| f.read}
    xmlDoc = Nokogiri::HTML.parse(talker_data)
    xmlDoc.xpath('//script').each do |log_node|
      event = @parser.parse_node(log_node)

      unless event.nil?
        if event.is_a?(Array)
          event.each {|evt| @collection.add_event(evt)}
        else
          @collection.add_event(event)
        end
      end
    end
    
    @collection.entries.length.should == 60
  end
  
  it "should accept quit messages" do
    event = '{ "time": 1270196596, "id": "e93a77b0205e012de69812313d01d943", "type": "leave", "room": { "name": "Main", "id":
819 }, "user": { "name": "fred", "id": 2657, "email": "fred@someserver.com" } }'
    event = @parser.parse_event(ActiveSupport::JSON.decode(event))
    event[:name].should == :userDisconnected
    event[:source].should == "talker://Main"
    event[:content].should == "joined"
    event[:occurred].to_s.should == "Fri Apr 02 09:23:16 +0100 2010"
    event[:sender][:name].should == 'fred'
  end
  
  it "should accept join messages" do
    event = '{ "time": 1270196430, "id": "867baae0205e012de69812313d01d943", "type": "join", "room": { "name": "Main", "id": 819
  }, "user": { "name": "frodo", "id": 2657, "email": "frodo@someserver.com" } }'
    event = @parser.parse_event(ActiveSupport::JSON.decode(event))
    event[:name].should == :userAvailable
    event[:source].should == "talker://Main"
    event[:content].should == "left"
    event[:occurred].to_s.should == "Fri Apr 02 09:20:30 +0100 2010"
    event[:sender][:name].should == 'frodo'
  end
end