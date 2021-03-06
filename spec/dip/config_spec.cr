require "../spec_helper"

describe Dip::Config do
  config = Dip::Config.from_yaml(File.read("./spec/dip.yml"))

  describe "version" do
    it "returns version number" do
      config.version.should eq("1")
    end
  end

  describe "environment" do
    it "returns env variables from dip.yml" do
      ENV.delete("RUBY")
      ENV.delete("RAILS_ENV")

      config.environment["RUBY"].should eq("2.3.1")
      config.environment["RAILS_ENV"].should eq("development")
    end
  end

  describe "provision" do
    it "returns array of provision commands" do
      config.provision.should eq(["bundle install", "bundle exec rake db:migrate"])
    end
  end
end
