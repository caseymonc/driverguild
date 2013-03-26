request = require "request"

module.exports = (Driver, EventController) =>
	
	renderDriverList: (req, res)=>
		console.log "Render Driver"
		Driver.getAllRegisteredDrivers (err, drivers)=>
			for driver in drivers
				driver.deliveries = [] if not driver.deliveries
				driver.deliveries.filter (delivery)=>
					return not (typeof delivery.complete == "undefined")
				console.log driver.name + " " + driver.deliveries
			drivers.sort (driver1, driver2)=>
				return driver2.deliveries.length - driver1.deliveries.length

			return res.json {error: err} if err
			res.render('index', {title: "Drivers", drivers: drivers})

	registerDriver: (body)=>
		console.log "Test"
		Driver.registerDriver body.uri, body.name, (err, driver)=>


	unRegisterDriver: (body)=>
		Driver.unRegisterDriver body.uri

	deliveryReady: (body)=>
		Driver.getAllRegisteredDrivers (err, drivers)=>
			return console.log err if err
			EventController.sendExternalEvent driver.uri, "rfq", "delivery_ready", body for driver in drivers

	bidAwarded: (body)=>
		bid = body.bids[0]
		EventController.sendExternalEvent bid.driverUri, "rfq", "bid_awarded", body
		Driver.addDelivery bid.driverUri, {price: bid.bid, due: body.deliveryTime, delivery_id: body.delivery_id}, (err)=>
			return console.log err if err
			console.log "Succeeded?"


	deliveryPickedUp: (body)=>
		bid = body.bids[0]
		Driver.pickedUp bid.driverUri, body.delivery_id, (err)=>
			return console.log err if err
			console.log "Succeeded?"


	deliveryComplete: (body)=>
		Driver.complete body.driverUri, body.delivery_id, (err)=>
			return console.log err if err
			console.log "Succeeded?"


