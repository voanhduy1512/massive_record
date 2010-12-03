require 'spec_helper'
require 'orm/models/person'
require 'orm/models/address'

shared_examples_for "validateable massive record model" do
  it "should include ActiveModel::Validations" do
    @model.class.included_modules.should include(ActiveModel::Validations)
  end

  describe "behaviour from active model" do
    it "should respond to valid?" do
      @model.should respond_to :valid?
    end

    it "should respond to errors" do
      @model.should respond_to :errors
    end

    it "should have one error" do
      @invalidate_model.call(@model)
      @model.valid?
      @model.should have(1).error
    end
  end

  describe "persistance" do
    it "should not interrupt saving of a model if its valid" do
      @model.save.should be_true
      @model.should be_persisted
    end


    it "should return false on save if record is not valid" do
      @invalidate_model.call(@model)
      @model.save.should be_false
    end

    it "should not save recurd if record is not valid" do
      @invalidate_model.call(@model)
      @model.save
      @model.should be_new_record
    end

    it "should skip validation if asked to" do
      @invalidate_model.call(@model)
      @model.save :validate => false
      @model.should be_persisted
    end

    it "should raise record invalid if save! is called on invalid record" do
      @invalidate_model.call(@model)
      @model.should_receive(:valid?).and_return(false)
      lambda { @model.save! }.should raise_error MassiveRecord::ORM::RecordInvalid
    end

    it "should raise record invalid if create! is called with invalid attributes" do
      @invalidate_model.call(@model)
      @model.class.stub(:new).and_return(@model)
      lambda { @model.class.create! }.should raise_error MassiveRecord::ORM::RecordInvalid
    end
  end
end


describe "MassiveRecord::Base::Table" do
  before do
    @model = Person.new :name => "Alice", :email => "alice@gmail.com", :age => 20
    @invalidate_model = Proc.new { |p| p.name = nil }
  end

  it_should_behave_like "validateable massive record model"
end

describe "MassiveRecord::Base::Column" do
  before do
    @model = Address.new :street => "Henrik Ibsens gate 1"
    @invalidate_model = Proc.new { |a| a.street = nil }
  end

  it_should_behave_like "validateable massive record model"
end