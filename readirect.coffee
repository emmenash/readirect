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
    @asMatcher ->
      @regex = regex

  redirect: (redirectAddress)->
    @asMatcher ->
      @redirectAddress = redirectAddress

  asMatcher: (fn)->
    m = @matcher()
    fn.call m
    m.return()

  matcher: ->
    if @isMatcher
      return this
    m = Object.create this
    m.isMatcher = yes
    m.complete = false
    m.return = =>
      if m.regex? and m.redirectAddress?
        m.complete = true
        @matchers.push m unless @matchers.indexOf(m) >= 0
        return this
      else
        return m
    m.match =->m.regex.exec.apply m.regex, arguments
    m
