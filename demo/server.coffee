connect = require 'connect'
connect.static = require 'serve-static'

server = connect()

readirect = require '../readirect'
rx = require 'regexify'

server.use '/badge', do ->
  readirect().from.referrer rx "/#{rx /[^\/]+$/}"
  .to (page)->"#{page}.png"
server.use connect.static __dirname
server.use (req, res)->
  res.setHeader 'content-type', 'text/html'
  res.end '<img src="/badge">'

server.listen 9001