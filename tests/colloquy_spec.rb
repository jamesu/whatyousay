require 'spec_helper'

describe ColloquyParser do
  before do
    @collection = LogCollection.new
    @parser = ColloquyParser.new(@collection)
  end
  
  it "should parse messages" do
    colloquy_data = File.open("tests/fixtures/sample.colloquyTranscript") {|f| f.read}
    xmlDoc = Nokogiri::XML.parse(colloquy_data)
    
    xmlDoc.xpath('log/*').each do |node|
      event = @parser.parse_node(node)
      event.should_not == nil
      
      if node.name == 'envelope'
        event.length.should == node.xpath("*").length-1
      end
    end
  end
  
  it "should accept quit messages" do
    doc = Nokogiri::XML.parse('<event id="VI5I5ZUHY2" name="userDisconnected" occurred="2010-09-02 12:49:53 +0100"><message>JohnSmith disconnected from the server.</message></event>')
    event = @parser.parse_node(doc.children[0])
    event[:type].should == :userDisconnected
    event[:content].should == "JohnSmith disconnected from the server."
    event[:occurred].to_s.should == "Thu Sep 02 12:49:53 +0100 2010"
    event[:sender].should == nil
  end
  
  it "should accept join messages" do
    doc = Nokogiri::XML.parse('<event id="D1U7LH65IY2" name="userAvailable" occurred="2010-09-02 16:30:17 +0100"><message><span class="member">JohnSmith</span> is now available.</message></event>')
    event = @parser.parse_node(doc.children[0])
    event[:type].should == :userAvailable
    event[:content].should == "JohnSmith is now available."
    event[:occurred].to_s.should == "Thu Sep 02 16:30:17 +0100 2010"
    event[:sender].should == nil
  end
end