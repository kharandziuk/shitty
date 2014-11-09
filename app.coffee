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

MongoClient.connect(url, (err, db)->
  throw err if err?

  app = express()
  C = {
    users: db.collection('users')
    requests: db.collection('requests')
    sessions: db.collection('sessions')
  }
  jwauth = require('./lib/jwauth')(app, C.users)

  app.set('jwtTokenSecret', 'YOUR_SECRET_STRING')

  app.use(bodyParser.json())
  app.use(cors())

  app.use('/status', jwauth)

  app.get('/status', (req, res)->
    res.json(kind: res.user.status or 'pre')
  )

  PHOTO_COUNT = 5


  app.use('/session', jwauth)

  app.get('/session', (req, res)->
    if req.user.gender is 'male'
      res.json(fbId: '100001677418300')
    else if req.user.gender is 'female'
      res.json(fbId: '820673977998508')
  )
  ress = []
  app.post('/session', (req, res)->
    ress.push(res)
    console.log 'post:session'
    if ress.length is 2
      _(ress).each((res)->
        res.end('you will newer see this')
      )
  )


  requestsHandler = ->
    C.requests.find(
      {gender: 'female', isCurrent: true}
    ).toArray((err, girls)->
      if girls.length > PHOTO_COUNT
        C.requests.find(
          {gender: 'boys', isCurrent: true}
        ).toArray((err, boys)->
          if boys.length > PHOTO_COUNT
            fiveBoys = boys[..PHOTO_COUNT]
            fiveGirls = girls[..PHOTO_COUNT]
            C.sessions.insert(
              boys: boys, girls: girls
            )
            all = _.union(boys, girls)
            ObjectID = require('mongodb').ObjectID
            assert(all.length is PHOTO_COUNT*2)
            _(all).each((user)->
              C.users.findAndModify(
                {_id: new ObjectID(user._id)}
                [['_id','asc']],
                {$set: {status: 'choose'}}
                {upsert: true},
                (err, user)->
                  console.log user
              )
              C.requests.findAndModify(
                { 'userId': user._id}
                [['_id','asc']],
                {$set: {isCurrent: false}}
                {upsert: true},
                (err, user)->
                  console.log user
              )
            )
            # create session
            # update boys
        )
    )
    

  app.post('/requests', (req, res)->
    isLucky = req.body.isLucky
    C.requests.find({isActive: True}).toArray((err, requests)->
        throw err if err?
        if users.length is 0
          C.users.findAndModify(
            {_id: new ObjectID(user._id)}
            [['_id','asc']],
            {$set: {status: 'pre_choose'}}
            {upsert: true},
            (err, user)->
              console.log user
          )
          C.requests.insert(
            {
              userId: req.user._id, isLucky: isLucky,
              isActive: True, gender: req.user.gender
            },
            {w: 1},
            (err, obj)->
              throw err if err?
              res.json(obj)
          )
        else
          res.write('you already have an active request')
          res.statusCode = 400
          res.end()
      )
  )
  app.post('/login', (req, res)->
      if (not req.body.fbToken?)
          res.write('provide fb token')
          res.statusCode = 400
          res.end()
          return
      console.log req.body
      unirest
          .get('https://graph.facebook.com/me')
          .qs(access_token: req.body.fbToken)
          .type('json')
          .end((fbRes)->
              if (not fbRes.error and fbRes.status is 200)
                  resJson = JSON.parse(fbRes.body)
                  console.log resJson
                  user = {
                      fid: resJson.id
                      gender: resJson.gender
                  }
                  if not user.gender?
                    res.write('decide you gender and return')
                    res.statusCode = 403
                    res.end()
                    return
                  if user.gender not in ['male', 'female']
                    res.write('now we work only with boys and girls. Sorry!')
                    res.statusCode = 403
                    res.end()
                    return
                  C.users.findAndModify(
                    user,
                    [['_id','asc']],
                    user,
                    {new: true, upsert: true},
                    (err, user)->
                      throw err if err?
                      console.log user._id
                      token = jwt.encode({
                        iss: user._id,
                      }, app.get('jwtTokenSecret'))
                      res.json(
                        token: token, fbId: resJson.id
                        gender: resJson.gender
                      )
                  )
              else
                  assert false, fbRes.body
          )
  )

  #assert.equal(null, err)
  console.log("Connected correctly to db")
  app.listen(3000)
)
