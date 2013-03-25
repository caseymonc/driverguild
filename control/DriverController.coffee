request = require "request"

module.exports = (Driver, EventController) =>
	
	registerDriver: (body)=>
		console.log "Test"
		Driver.registerDriver body.uri, (err, driver)=>


	unRegisterDriver: (body)=>
		Driver.unRegisterDriver body.uri

	deliveryReady: (body)=>
		Driver.getAllRegisteredDrivers (err, drivers)=>
			return console.log err if err
			EventController.sendExternalEvent driver.uri, "rfq", "delivery_ready", data for driver in drivers

	bidAwarded: (body)=>
		bid = body.bids[0]
		EventController.sendExternalEvent bid.driverUri, "rfq", "bid_awarded", body

	deliveryPickedUp: (body)=>
		#Track delivery picked up


	deliveryComplete: (body)=>
		#Track delivery completed


