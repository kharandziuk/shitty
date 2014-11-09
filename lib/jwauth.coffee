url = require('url')
jwt = require('jwt-simple')

module.exports = (app, db)->
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
    token = req.body.token
    if token?
      try
        decoded = jwt.decode(token, app.get('jwtTokenSecret'))
      catch error
        null
      if decoded?
        ObjectID = require('mongodb').ObjectID
        db.findOne({ '_id': new ObjectID(decoded.iss) }, (err, user)->
          throw err if (err?)
          console.log 'd', user
          req.user = user
          return next()
        )
      else
        res.end('Not authorized', 401)
        return
    else
      res.end('Not authorized', 401)
      return
