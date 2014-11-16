Online = require "../src/online"

describe "Sloef.Online", () ->
  it "should detect online pages", (done) ->
    Online.onlineCheck("http://www.google.be").then () ->
      done()
    .done new Error "should not be reached"

  it "should detect offline pages", (done) ->
    Online.onlineCheck("http://www.ithingimnotonline.be").then () ->
      done new Error "this url should not be online"
    .fail (err) ->
      done()
    .done new Error "should not be reached"

  it "should retry multiple times", (done) ->
    Online.onlineCheckWithRetry("http://www.google.be").then () ->
      done()
    .done new Error "should not be reached"

  it "should retry multiple times, on non existing sites too", (done) ->
    Online.onlineCheckWithRetry("http://www.ithingmaosdflinonline.be", 2, 5).then () ->
      done new Error "this url should not be online"
    .fail (err) ->
      done()
    .done new Error "should not be reached"
