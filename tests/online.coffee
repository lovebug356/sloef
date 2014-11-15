onlineCheck = require "../src/online"

describe "Sloef.Online", () ->
  it "should detect online pages", (done) ->
    onlineCheck("http://www.google.be").then () ->
      done()
    .done new Error "should not be reached"
  it "should detect offline pages", (done) ->
    onlineCheck("http://www.ithingimnotonline.be").then () ->
      done new Error "this url should not be online"
    .fail (err) ->
      done()
    .done new Error "should not be reached"
