require File.dirname(__FILE__) + '/../spec_helper'

describe Asset do
  it "should have the attributes of an Asset" do
    Asset.new.should respond_to(:name, :type, :title, :description, :filesize,
                                :created_at, :thumbnail, :status, :file,
                                :converted, :hidden_url, :pages, :duration,
                                :artist, :track_title, :height, :width,
                                :contents, :url)
  end
end
