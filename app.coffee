express = require 'express'
fs = require 'fs'
MemoryStore = require('express').session.MemoryStore
Mongoose = require 'mongoose'
DeliveryModel = require './model/Delivery'
DriverModel = require './model/Driver'
request = require "request"
https = require('https')
event = require('events')
EventEmitter = new event.EventEmitter()
EventController = require("./control/EventController")(EventEmitter)

DB = process.env.DB || 'mongodb://localhost:27017/shop'
db = Mongoose.createConnection DB

Delivery = DeliveryModel db
Driver = DriverModel db

DriverControl = require './control/DriverController'
DriverController = new DriverControl(Driver, EventController)

mongomate = require('mongomate')('mongodb://localhost')

PORT = 3040
exports.createServer = ->

	app = express()

	app.configure ->
		app.use(express.cookieParser())
		app.use(express.bodyParser())
		app.use(express.methodOverride())
		app.use(express.session({ secret: 'keyboard cat' }))
		app.use('/db', mongomate);
		
		app.set('view engine', 'jade')
		app.use(app.router)
		app.use(express.static(__dirname + "/public"))
		app.set('views', __dirname + '/public')
		app.use('/javascript', express.static(__dirname + "/public/javascript"))


	app.get '/', (req, res)->
		res.render('index', {title: "FlowerShop/Driver"})

	app.post '/event', (req, res)->
		console.log "Sent Event"
		EventController.handleEvent req, res
		res.send "OK"


	EventEmitter.on "rfq:delivery_ready", (body)=>
		DriverController.deliveryReady body

	EventEmitter.on 'rfq:bid_awarded', (body)=>
		DriverController.bidAwarded body

	EventEmitter.on 'delivery:picked_up', (body)=>
		DriverController.deliveryPickedUp body

	EventEmitter.on 'delivery:complete', (body)=>
		DriverController.deliveryComplete body

	EventEmitter.on 'rfq:driver_ready', (body)=>
		DriverController.registerDriver body

	EventEmitter.on 'rfq:driver_done', (body)=>
		DriverController.unRegisterDriver body



	# final return of app object
	app

if module == require.main
	app = exports.createServer()
	app.listen PORT
	console.log "Running Foursquare Service on port: " + PORT
