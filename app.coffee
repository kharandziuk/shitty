assert = require 'assert'
_ = require 'underscore'
express = require 'express'
bodyParser = require('body-parser')
jwt = require('jwt-simple')
unirest = require 'unirest'
cors = require('cors')
MongoClient = require('mongodb').MongoClient
url = 'mongodb://172.17.0.7:27017/myproject'
Bourne  = require("bourne")
db = null
jwauth = null

jwauthFactory = require './lib/jwauth'

app = express()

#comments = new Bourne("simpleBlogComments.json")

app.set('jwtTokenSecret', 'YOUR_SECRET_STRING')

token = 'CAAVqMpHVobQBAPfsAZBksRZAplom8kXZAZArAyOj6sE1HO85FRMf8KiOBTSYRCSrqXDyYZAYwY5thsiuFZAVQQxCtWNlQuaKHISnqqAOTtuU85hYGytlc6j2o4l5WWGtJEWylRbSZCcmAogi6DAEBXZChQ0H6hhL0cUoVVR9kh1l6MsglJhLOgOGohccdWCvIiZB78wC5uyjZC9OHyUVNfLbLOovjnNS92nyIZD'

app.use(bodyParser.json())
app.use(cors())

app.post('/login', (req, res)->
    if (not req.body.fbToken?)
        console.log 'the'
        res.write('provide fb token')
        res.statusCode = 400
        res.end()
        return
    console.log req.body
    unirest
        .get('https://graph.facebook.com/me')
        .qs(access_token: req.body.fbToken)
        .end((fbRes)->
            if (not fbRes.error and fbRes.status is 200)
                user = {
                    fid: fbRes.body.id
                }
                users = db.collection('users')
                users.findAndModify(user, [['_id','asc']], user, {new: true, upsert: true}, (err, user)->
                    throw err if err?
                    console.log user._id
                    token = jwt.encode({
                      iss: user._id,
                    }, app.get('jwtTokenSecret'))
                    res.json(token: token)
                )
                  #)

            else
                assert false, fbRes.body
        )
)


MongoClient.connect(url, (err, openDb)->
  #assert.equal(null, err)
  throw err if err?
  console.log("Connected correctly to db")
  db = openDb
  jwauth = jwauthFactory(db.collection('users'))
  app.listen(3000)
)
