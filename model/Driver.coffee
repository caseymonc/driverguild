mongoose = require 'mongoose'
Schema = mongoose.Schema

# User Model
module.exports = (db) ->

	DriverSchema = new Schema({
		uri: { type: String, unique: true },
		deliveries: [{price: Number, pickup: Date, due: Date, complete: Date, delivery_id: String}]
	}, { collection : 'guild_drivers' })


	DriverSchema.statics.addDelivery = (driver_uri, delivery, cb)->
		@findOne({uri: driver_uri}).exec (err, driver)=>
			return cb err if err
			return cb {error : "No Driver"} if not driver
			driver.deliveries = [] if not driver.deliveries?
			driver.deliveries.push(delivery)
			driver.save (err)=>
				return cb err if err?
				cb null, driver

	DriverSchema.statics.pickedUp = (driver_uri, delivery_id, cb)->
		@findOne({uri: driver_uri}).exec (err, driver)=>
			return cb err if err
			return cb {error : "No Driver"} if not driver
			return cb {error : "No Deliveries"} if not driver.deliveries
			for delivery in driver.deliveries
				if delivery.delivery_id == delivery_id
					delivery.pickup = new Date()
					break
			driver.save (err)=>
				return cb err if err?
				cb null, driver

	DriverSchema.statics.complete = (driver_uri, cb)->
		@update({uri: driver_uri}, {complete: new Date()}).exec cb

	DriverSchema.statics.getAllRegisteredDrivers = (cb) ->
		@find().exec cb

	DriverSchema.statics.registerDriver = (uri, cb) ->
		console.log "Uri: " + uri
		@find({uri: uri}).exec (err, driver)=>
			#return cb err if err?
			console.log driver if driver?
			return cb {"error", "Already Exists"} if driver?

			driverData = {uri: uri}
			Driver driver = new Driver driverData
			driver.save (err)=>
				return cb err if err?
				cb null, driver


	DriverSchema.statics.unRegisterDriver = (uri, cb) ->
		@remove({uri: uri}).exec cb



	Driver = db.model "Driver", DriverSchema