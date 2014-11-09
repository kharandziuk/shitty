url = require('url')
jwt = require('jwt-simple')

module.exports = (db)->
  return (req, res, next)->
    parsed_url = url.parse(req.url, true)
    ###
    * Take the token from:
    * 
    *  - the POST value access_token
    *  - the GET parameter access_token
    *  - the x-access-token header
    *    ...in that order.
    * 
    ###
    token = (req.body and req.body.access_token) or
      parsed_url.query.access_token or req.headers["x-access-token"]
    if (token)
      try
        decoded = jwt.decode(token, app.get('jwtTokenSecret'))
        db.findOne({ '_id': decoded.iss }, (err, user)->
          if (!err)
            req.user = user
            return next()
        )
      catch
        res.end('Not authorized', 401)
        return
    else
      res.end('Not authorized', 401)
      return
