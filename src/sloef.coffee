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
    if retryCount > 1
      return Q.delay(retryDelay).then () ->
        onlineCheckWithRetry url, retryDelay, retryCount-1
      .fail (err) ->
        throw new Error "onlineCheck #{url}: Failed #{retryCount} times"
    else
      throw new Error "onlineCheck #{url}: Failed #{retryCount} times"

sendEmailWhenOffline = (url, retryDelay=1000, retryCount=1, emailConfiguration) ->
  onlineCheckWithRetry(url, retryDelay, retryCount).fail (err) ->
    server = email.server.connect emailConfiguration.server
    server.send
      from: emailConfiguration.from
      to: emailConfiguration.to
      subject: "sloef report: #{url} is online for #{retryCount} times"
      text: err.message

loadConfiguration = () ->
  pifpaf.isFile(".sloef.json").then () ->
    return require ".sloef.json"
  .fail () ->
    pifpaf.isFile("/etc/sloef.json").then () ->
      return require "/etc/sloef.json"
    throw new Error "sloef: did not find configuration file"

if module.parent == null
  loadConfiguration().then (configuration) ->

module.exports.onlineCheck = onlineCheck
module.exports.onlineCheckWithRetry = onlineCheckWithRetry
module.exports.sendEmailWhenOffline = sendEmailWhenOffline
