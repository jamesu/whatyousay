require 'spec_helper'

describe JSONParser do
  before do
    @collection = LogCollection.new
    @parser = JSONParser.new(@collection)
  end
  
  it "should parse messages" do
    json_data = File.open("spec/fixtures/sample.json") {|f| f.read}
    @parser.parse(StringIO.new(json_data))
    
    @collection.entries.length.should == 11
    @collection.senders.length.should == 2
    @collection.senders['johnsmith'].should_not == nil
    @collection.senders['myself'].should_not == nil
  end
end