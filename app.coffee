_ = require 'underscore'
express = require 'express'
bodyParser = require('body-parser')
jwt = require('jwt-simple')
unirest = require 'unirest'
cors = require('cors')

app = express()

app.set('jwtTokenSecret', 'YOUR_SECRET_STRING')

app.use(bodyParser.json())
app.use(cors())
token = 'CAAVqMpHVobQBACdNZBMK17HgMTR1L3YdVnzpNOvK0LmBEBM9zNEuua5T5aH2h94cxLYQQSQZAY0SRPbZBJ0uNFylJuZAiowZB5SAhvmXDEKFIaejDBGERILYxQRZCm9FN2VZBJKoVbVPsdKRpq4MfEq7vkwC8ZB5xsbVF3JvxTZBZBBTUd1pd9yZC5qbzTBgZAstQSdyU2XS5zfJZCnt9Gqiae1HILoAyZCmQm2LoZD'
app.post('/login', (req, res)->
    if (not req.body.fbToken?)
        console.log 'the'
        res.write('provide fb token')
        res.statusCode = 400
        res.end()
        return
    unirest
        .get('https://graph.facebook.com/me')
        .qs(access_token: token)
        .end((fbRes)->

            if (not fbRes.error and fbRes.status is 200)
                  console.log(fbRes.body) # Print the google web page.
            token = jwt.encode({
                iss: user.id,
            }, app.get('jwtTokenSecret'))
        )
)


app.listen(3000)
