module.exports = class Readirect
  constructor: ->
    unless this instanceof Readirect
      return new Readirect
    @matchers = []

  handle: (req, res, next)->
    redirect =(url)->
      res.statusCode = 302
      res.setHeader 'Location', url
      res.setHeader 'Content-Length', '0'
      res.end()
      
    for matcher in @matchers
      if (m = matcher.match req.headers.referer)
        return redirect matcher.redirectAddress.apply(null, m[1..])
    next()

  from: (regex)->
    m = new Matcher regex
    @matchers.push m
    m

  @Matcher: class Matcher
    constructor: (@regex)->

    match: ->@regex.exec.apply @regex, arguments
    redirect: (@redirectAddress)->