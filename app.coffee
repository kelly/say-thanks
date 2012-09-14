express = require("express")
http    = require("http")
path    = require("path")
sys = require("util")
oauth = require("oauth")
twitter = require('ntwitter')

twitterConsumerKey = "uK6vJIkW7iHOuJ5xiQKw"
twitterConsumerSecret = "qW5YD1dRevGscGKTPRpMkvIp0DqP0XdGTKbXYSFrk"
twitterAccessKey = "821863411-yHcFetg2VzwQtuD1V0AxD7Kbv7OHgXpUiLNT8rum"
twitterAccessSecret = "im1KtkbBaW3a57xg4RIQ06MeSKIDJZKS2nGcXRamc"
listID = 77347585

twit = new twitter
  consumer_key: twitterConsumerKey
  consumer_secret: twitterConsumerSecret
  access_token_key: twitterAccessKey
  access_token_secret: twitterAccessSecret

props = ['Thanks', 'Congrats', 'Good Job', 'Inspiring', 'Speedy', 'Awesome', 'Interesting', 'You Rock']

consumer = ->
  new oauth.OAuth("https://twitter.com/oauth/request_token", "https://twitter.com/oauth/access_token", twitterConsumerKey, twitterConsumerSecret, "1.0A", "http://192.168.0.195:3001/sessions/callback", "HMAC-SHA1")

app = express.createServer()

app.configure ->
  app.set "port", process.env.PORT or 3001
  app.set "views", __dirname + "/views"
  app.set "view engine", "hbs"
  app.use express.favicon()
  app.use express.cookieParser()
  app.use express.session({ secret: 'blahblah' })
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.dynamicHelpers messages: require('express-messages') 

app.dynamicHelpers session: (req, res) ->
  req.session

app.get "/", (req, res) ->
  console.log 
  if req.session.oauthRequestToken 
    twit.getListMembers listID, '', (err, data) ->
      console.log err
      console.log data
      employees = data
      res.render 'index',
        locals:
          props: props
          title: 'say:thanks'
          employees: employees
  else 
    res.redirect '/sessions/connect'

app.get "/success", (req, res) ->
  res.render 'success',
    locals:
      title: 'say:thanks'


app.post "/", (req, res) ->
  twit.updateStatus "@#{req.body.entry.to} Hey, #{props[req.body.entry.prop]}! For doing #{req.body.entry.body} - from @#{req.session.screen_name}", (err, data) ->
    res.redirect '/success'


app.get "/entries", (req, res) ->

app.get "/sessions/connect", (req, res) ->
  consumer().getOAuthRequestToken (error, oauthToken, oauthTokenSecret, results) ->
    if error
      res.send "Error getting OAuth request token : " + sys.inspect(error), 500
    else
      req.session.oauthRequestToken = oauthToken
      req.session.oauthRequestTokenSecret = oauthTokenSecret
      res.redirect "https://twitter.com/oauth/authorize?oauth_token=" + req.session.oauthRequestToken

app.get "/sessions/callback", (req, res) ->
  sys.puts ">>" + req.session.oauthRequestToken
  sys.puts ">>" + req.session.oauthRequestTokenSecret
  sys.puts ">>" + req.query.oauth_verifier
  consumer().getOAuthAccessToken req.session.oauthRequestToken, req.session.oauthRequestTokenSecret, req.query.oauth_verifier, (error, oauthAccessToken, oauthAccessTokenSecret, results) ->
    if error
      res.send "Error getting OAuth access token : " + sys.inspect(error) + "[" + oauthAccessToken + "]" + "[" + oauthAccessTokenSecret + "]" + "[" + sys.inspect(results) + "]", 500
    else
      req.session.oauthAccessToken = oauthAccessToken
      req.session.oauthAccessTokenSecret = oauthAccessTokenSecret
      
      # Right here is where we would write out some nice user stuff
      consumer().get "http://twitter.com/account/verify_credentials.json", req.session.oauthAccessToken, req.session.oauthAccessTokenSecret, (error, data, response) ->
        if error
          res.send "Error getting twitter screen name : " + sys.inspect(error), 500
        else
          # console.log "data is %j", data
          # console.log "token: #{req.session.oauthAccessToken}"
          # console.log "token: #{req.session.oauthAccessTokenSecret}"

          data = JSON.parse(data)
          req.session.screen_name= data["screen_name"]
          res.redirect '/'
          req.flash "Logged in as #{data['name']}"

app.listen parseInt(process.env.PORT or 3001)