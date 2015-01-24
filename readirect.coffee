module.exports = class Readirect
  constructor: ->
    unless this instanceof Readirect
      return new Readirect
    @matchers = []

    # `.from` keeps a reference to the middleware instance,
    # sort of like closing any open matchers
    @from = this

  handle: (req, res, next)->
    redirect =(url)->
      res.statusCode = 302
      res.setHeader 'Location', url
      res.setHeader 'Content-Length', '0'
      res.end()

    for matcher in @matchers
      if (args = matcher.match(req))
        return redirect matcher.redirectCallback.apply({req, res, next}, args)
    next()

  # matcher can have any number of patterns, they're applied in order
  operators =
    referrer: {header: 'referer'}
    referer: {header: 'referer'}
    url: {prop: 'url'}
  operators.referer = operators.referrer

  for key, options of operators
    do (key, options)=>
      @::[key] = (regex)->
        @asMatcher ->
          options.regex = regex
          @patterns.push options

  to: (cb)->
    @asMatcher ->
      @redirectCallback = cb

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
    m.patterns = []
    m.return = =>
      if m.complete
        return this
      else
        return m
    m.match =(req)->
      a = m.patterns.reduce (args, p)->
          return null unless args
          c = if p.header
            req.headers[p.header]
          else if p.prop
            req[p.prop]
          if result = p.regex.exec c
            args.concat result[1..]
        , []
      a

    @matchers.push m
    m
