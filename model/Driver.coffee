mongoose = require 'mongoose'
Schema = mongoose.Schema

# User Model
module.exports = (db) ->

	DriverSchema = new Schema({
		uri: { type: String, unique: true }
	}, { collection : 'drivers' })


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