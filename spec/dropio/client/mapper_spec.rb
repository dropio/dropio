require File.dirname(__FILE__) + '/../../spec_helper'

describe Client::Mapper do
  it "should parse Drops" do
    test_drop = Client::Mapper.map_drops <<-RESPONSE
      {"rss":"http:\/\/drop.io\/k4gpvnty6tw9ho8u3j4w\/b9b2c8f2b8e655679d2fb62b83f8efec4fb4c8af\/test_drop.rss",
       "voicemail":"646-495-9201 x 02302",
       "email":"test_drop@drop.io",
       "admin_token":"A97KQ4Vk7qQU90",
       "fax":"856-632-1999",
       "conference":" 218-486-3891 x 915088666",
       "name":"test_drop",
       "upload_url":"http:\/\/assets.drop.io\/upload",
       "guests_can_add":"true",
       "guests_can_comment":"true",
       "guests_can_delete":"false",
       "current_bytes":51488,
       "max_bytes":104857600.0,
       "expiration_length":"1_YEAR_FROM_LAST_VIEW",
       "delete_permission_type":"ALLOWED"}
    RESPONSE
    
    test_drop.should be_an_instance_of(Drop)
    test_drop.rss.should                    == "http:\/\/drop.io\/k4gpvnty6tw9ho8u3j4w\/b9b2c8f2b8e655679d2fb62b83f8efec4fb4c8af\/test_drop.rss"
    test_drop.voicemail.should              == "646-495-9201 x 02302"
    test_drop.email.should                  == "test_drop@drop.io"
    test_drop.admin_token.should            == "A97KQ4Vk7qQU90"
    test_drop.fax.should                    == "856-632-1999"
    test_drop.conference.should             == " 218-486-3891 x 915088666"
    test_drop.name.should                   == "test_drop"
    test_drop.upload_url.should             == "http:\/\/assets.drop.io\/upload"
    test_drop.guests_can_add.should         == "true"
    test_drop.guests_can_comment.should         == "true"
    test_drop.guests_can_delete.should         == "false"
    test_drop.current_bytes.should          == 51488
    test_drop.max_bytes.should              == 104857600.0
    test_drop.expiration_length.should      == "1_YEAR_FROM_LAST_VIEW"
  end
  
  it "should parse lists of Drops" do
    drops = Client::Mapper.map_drops <<-RESPONSE
      [{"rss":"http:\/\/drop.io\/k4gpvnty6tw9ho8u3j4w\/b9b2c8f2b8e655679d2fb62b83f8efec4fb4c8af\/test_drop.rss",
        "voicemail":"646-495-9201 x 02302",
        "email":"test_drop@drop.io",
        "admin_token":"A97KQ4Vk7qQU90",
        "fax":"856-632-1999",
        "conference":" 218-486-3891 x 915088666",
        "name":"test_drop",
        "upload_url":"http:\/\/assets.drop.io\/upload",
        "guests_can_add":"true",
        "guests_can_comment":"true",
        "guests_can_delete":"false",
        "current_bytes":51488,
        "max_bytes":104857600.0,
        "expiration_length":"1_YEAR_FROM_LAST_VIEW"},
       {"current_bytes":178857,
        "max_bytes":104857600.0,
        "voicemail":"646-495-9201 x 72025",
        "admin_token":"8a8vfzfvs2",
        "email":"0sdcmz7@drop.io",
        "upload_url":"http:\/\/assets.drop.io\/upload",
        "guests_can_add":"true",
        "guests_can_comment":"true",
        "guests_can_delete":"false",
        "conference":" 218-486-3891 x 680277944",
        "name":"0sdcmz7",
        "expiration_length":"1_YEAR_FROM_LAST_VIEW",
        "fax":"856-632-1999",
        "rss":"http:\/\/drop.io\/no9mbevuq3ttmfi6kqen\/3ec4f87d720032bae579cca40740e5e4b267e090\/0sdcmz7.rss"}]
    RESPONSE
    
    drops.should be_an_instance_of(Array)
    drops.each_should be_an_instance_of(Drop)
    drops[0].name.should == "test_drop"
    drops[1].name.should == "0sdcmz7"
  end
  
  it "should parse Assets" do
    parent_drop = stub(Drop)
    audio = Client::Mapper.map_assets parent_drop, <<-RESPONSE
      {"type":"audio",
       "thumbnail":"http:\/\/drop.io\/download\/public\/vhahbqybv2dx2vdh0z7c\/8c525895399b8eafcd1621b4bd001ee1797e6679\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/",
       "status":"converted",
       "filesize":178857,
       "name":"audio",
       "file":"http:\/\/drop.io\/download\/48f660ba\/b3c057eb4ce606f2f9f478379ea94ab703416ab3\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/audio.mp3\/audio.mp3",
       "duration":11,
       "track_title":"Unknown",
       "artist":"Unknown",
       "created_at":"2008/10/15 21:28:55 +0000",
       "converted":"http:\/\/drop.io\/download\/48f660ba\/26f6688a110f481b169daaa0a023656d4688dac0\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/converted-audio_converted.mp3"}
    RESPONSE
    
    audio.should be_an_instance_of(Asset)
    audio.drop.should        == parent_drop
    audio.type.should        == "audio"
    audio.thumbnail.should   == "http:\/\/drop.io\/download\/public\/vhahbqybv2dx2vdh0z7c\/8c525895399b8eafcd1621b4bd001ee1797e6679\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/"
    audio.status.should      == "converted"
    audio.filesize.should    == 178857
    audio.name.should        == "audio"
    audio.file.should        == "http:\/\/drop.io\/download\/48f660ba\/b3c057eb4ce606f2f9f478379ea94ab703416ab3\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/audio.mp3\/audio.mp3"
    audio.duration.should    == 11
    audio.track_title.should == "Unknown"
    audio.artist.should      == "Unknown"
    audio.created_at.should  == "2008/10/15 21:28:55 +0000"
    audio.converted.should   == "http:\/\/drop.io\/download\/48f660ba\/26f6688a110f481b169daaa0a023656d4688dac0\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/converted-audio_converted.mp3"
  end

  it "should parse lists of Assets" do
    parent_drop = stub(Drop)
    assets = Client::Mapper.map_assets parent_drop, <<-RESPONSE
      [{"type":"note",
        "status":"converted",
        "filesize":109,
        "name":"about-these-files",
        "contents":"These files are vital to our mission.&nbsp; <strong>Please<\/strong> do not delete them.<br \/><br \/>Thank you.",
        "title":"About these files",
        "created_at":"2008/10/15 21:21:49 +0000"},
       {"type":"audio",
        "thumbnail":"http:\/\/drop.io\/download\/public\/vhahbqybv2dx2vdh0z7c\/8c525895399b8eafcd1621b4bd001ee1797e6679\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/",
        "status":"converted",
        "filesize":178857,
        "name":"audio",
        "file":"http:\/\/drop.io\/download\/48f660ba\/b3c057eb4ce606f2f9f478379ea94ab703416ab3\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/audio.mp3\/audio.mp3",
        "duration":11,
        "track_title":"Unknown",
        "artist":"Unknown",
        "created_at":"2008/10/15 21:28:55 +0000",
        "converted":"http:\/\/drop.io\/download\/48f660ba\/26f6688a110f481b169daaa0a023656d4688dac0\/1c073ae0-7d29-012b-f659-002241261481\/316995b0-7d2e-012b-b8db-002241261481\/converted-audio_converted.mp3"}]
    RESPONSE
    
    assets.should be_an_instance_of(Array)
    assets.each_should be_an_instance_of(Asset)
    assets[0].name.should == "about-these-files"
    assets[1].name.should == "audio"
  end

  it "should parse Comments" do
    parent_asset = stub(Asset)
    comment = Client::Mapper.map_comments parent_asset, <<-RESPONSE
      {"created_at":"2008/09/17 20:47:47 +0000",
       "id":1,
       "contents":"This is my comment content."}
    RESPONSE
    
    comment.should be_an_instance_of(Comment)
    comment.asset.should == parent_asset
    comment.created_at.should == "2008/09/17 20:47:47 +0000"
    comment.id.should         == 1
    comment.contents.should   == "This is my comment content."
  end

  it "should parse lists of Comments" do
    parent_asset = stub(Asset)
    comments = Client::Mapper.map_comments parent_asset, <<-RESPONSE
      [{"contents":"Really?  Looks like a waste of space to me.  I'm going to delete some of these...",
        "created_at":"2008/10/15 21:44:24 +0000",
        "id":1},
       {"contents":"DON'T DO IT!!",
        "created_at":"2008/10/15 21:44:36 +0000",
        "id":2}]
    RESPONSE
    
    comments.should be_an_instance_of(Array)
    comments.each_should be_an_instance_of(Comment)
    comments[0].contents.should =~ /waste of space/
    comments[1].contents.should =~ /DON'T/
  end
end
