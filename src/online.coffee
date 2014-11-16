http = require "http"
Q = require 'q'

onlineCheck = (url) ->
  defer = Q.defer()
  http.get url, (res) ->
    if res.statusCode != 200
      defer.reject new Error "onlineCheck #{url}: Expected statuscode 200, got statuscode #{res.statusCode}"
    else
      defer.resolve()
  .on 'error', (err) ->
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

module.exports.onlineCheck = onlineCheck
module.exports.onlineCheckWithRetry = onlineCheckWithRetry
