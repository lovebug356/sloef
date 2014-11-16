http = require "http"
Q = require 'q'
email = require 'emailjs'
pifpaf = require 'pifpaf'
path = require 'path'

onlineCheck = (url) ->
  defer = Q.defer()
  req = http.get url, (res) ->
    req.abort()
    if res.statusCode != 200
      defer.reject new Error "sloef: onlineCheck #{url}: Expected statuscode 200, got statuscode #{res.statusCode}"
    else
      defer.resolve()
  .on 'error', (err) ->
    req.abort()
    defer.reject err
  return defer.promise

onlineCheckWithRetry = (url, retryDelay=1000, retryCount=1) ->
  promise = onlineCheck(url).then () ->
    return
  .fail (err) ->
    console.log "sloef: #{url} is offline, retrying"
    if retryCount > 1
      return Q.delay(retryDelay).then () ->
        onlineCheckWithRetry url, retryDelay, retryCount-1
      .fail (err) ->
        throw new Error "sloef onlineCheck #{url}: Failed #{retryCount} times"
    else
      throw new Error "sloef onlineCheck #{url}: Failed #{retryCount} times"

sendEmailWhenOffline = (url, retryDelay=1000, retryCount=1, emailConfiguration) ->
  onlineCheckWithRetry(url, retryDelay, retryCount).then () ->
    console.log "sloef: #{url} is online"
  .fail (err) ->
    console.log "sloef: #{url} is offline"
    server = email.server.connect emailConfiguration.server
    server.send {
      from: emailConfiguration.from
      to: emailConfiguration.to
      subject: "sloef report: #{url} is offline for #{retryCount} times"
      text: err.message
    }

loadConfiguration = (id=0) ->
  candidateLocations = [
    path.join __dirname, "..", ".sloef.json"
    path.join "/", "etc", "sloef.json"
  ]
  if id < candidateLocations.length
    location = candidateLocations[id]
    return pifpaf.isFile(location).then (check) ->
      if check
        return require location
      else
        return loadConfiguration id + 1
  else
    throw new Error "sloef: did not find configuration file"

run = () ->
  loadConfiguration().then (configuration) ->
    for url in configuration.urls
      sendEmailWhenOffline(url, configuration.retryDelay, configuration.retryCount, configuration).done()
  .done()

if module.parent == null
  run()

module.exports.onlineCheck = onlineCheck
module.exports.onlineCheckWithRetry = onlineCheckWithRetry
module.exports.sendEmailWhenOffline = sendEmailWhenOffline
module.exports.loadConfiguration = loadConfiguration
module.exports.run = run
