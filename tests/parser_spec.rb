require 'spec_helper'

describe Parser do
  it "should parse xml-based messages" do
    collection = LogCollection.new
    parser = ColloquyParser.new(collection)
    colloquy_data = File.open("tests/fixtures/sample.colloquyTranscript") {|f| f.read}
    parser.parse(StringIO.new(colloquy_data))
    
    collection.senders.keys.length.should == 2
    collection.entries.length.should == 11
    
    collection.entries.first.content.should == "what?"
    collection.entries.last.content.should == "JohnSmith disconnected from the server."
  end
  
  it "should parse line-based messages" do
    collection = LogCollection.new
    parser = IrciiParser.new(collection)
    ircii_data = File.open("tests/fixtures/ircii.log") {|f| f.read}
    parser.parse(StringIO.new(ircii_data))
    
    collection.senders.keys.length.should == 9
    collection.entries.length.should == 28
    
    collection.entries.first.content.should == "has joined #letstalk"
    collection.entries.last.content.should == "fudgeing madness"
  end
end