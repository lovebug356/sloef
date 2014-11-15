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

module.exports = onlineCheck
