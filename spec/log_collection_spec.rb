require 'spec_helper'

describe LogCollection do
  before do
    @collection = LogCollection.new
  end

  describe "add_sender" do
    it "should add senders to the list and return a new Sender" do
      @collection.add_sender({:ident => 'foo'}).class.should == Sender
      @collection.senders.has_key?('foo').should_not == nil
    end

    it "should merge existing sender info when added more than once" do
      first_sender = @collection.add_sender({:ident => 'foo'})
      @collection.senders['foo'].should_receive(:merge).and_return(first_sender)
      @collection.add_sender({:ident => 'foo'}).should == first_sender
    end

    it "should accept old_name or name" do
      first_sender = @collection.add_sender({:ident => 'foo', :name => 'Foo'})
      @collection.add_sender({:name => 'Foo'}).should == first_sender
      @collection.add_sender({:old_name => 'Foo'}).should == first_sender
      @collection.add_sender({:name => 'MysteryFoo'}).should == nil
    end
  end

  describe "add_event" do
    it "should add a :sender if the event has specified one" do
      ident = {:ident => 'foo'}
      @collection.should_receive(:add_sender, ident)
      @collection.add_event({:sender => ident})
    end

    it "should add a log entry with the current source" do
      @collection.source = 'mystery'
      @collection.add_event({:sender => {:ident => 'foo'}})
      @collection.entries.length.should == 1
      @collection.entries[0].source.should == 'mystery'
      @collection.entries[0].sender.ident.should == 'foo'
    end
  end

  describe "limit_entries_by_time" do
    before do
      @collection.add_event({:sender => {:ident => 'foo'}, :content => '1', :occurred => Time.utc(2010,1,1,1,0,0)})
      @collection.add_event({:sender => {:ident => 'foo'}, :content => '2', :occurred => Time.utc(2010,1,1,1,0,1)})
      @collection.add_event({:sender => {:ident => 'foo'}, :content => '3', :occurred => Time.utc(2010,1,1,1,0,2)})
      @collection.add_event({:sender => {:ident => 'foo'}, :content => '4', :occurred => Time.utc(2010,1,1,1,0,3)})
    end

    it "should do nothing if start_time and end_time are nil" do
      @collection.limit_entries_by_time(nil, nil)
      @collection.entries.length.should == 4
    end

    it "should ignore all events before start_time if its set" do
      @collection.limit_entries_by_time(Time.utc(2010,1,1,1,0,3), nil)
      @collection.entries.length.should == 1
      @collection.entries[0].content.should == '4'
    end

    it "should ignore all events after end_time if its set" do
      @collection.limit_entries_by_time(nil, Time.utc(2010,1,1,1,0,1))
      @collection.entries.length.should == 1
      @collection.entries[0].content.should == '1'
    end

    it "should ignore all events outside '>= start_time < end_time' if they are both set" do
      @collection.limit_entries_by_time(Time.utc(2010,1,1,1,0,2), Time.utc(2010,1,1,1,0,3))
      @collection.entries.length.should == 1
      @collection.entries[0].content.should == '3'
    end
  end

  describe "clean_entries" do
    it "should remove duplicate entries" do
      @collection.add_event({:sender => {:ident => 'foo'}, :occured => Time.utc(2010,1,1)})
      @collection.add_event({:sender => {:ident => 'foo'}, :occured => Time.utc(2010,1,1)})
      @collection.entries.length.should == 2
      @collection.clean_entries
      @collection.entries.length.should == 1
    end
  end
end