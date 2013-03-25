mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = require('mongoose').Types.ObjectId

# Delivery Model
module.exports = (db) ->

	DeliverySchema = new Schema({
		flowerShopId: String,
		address: String,
		pickupTime: Date,
		deliveryTime: Date,
		bids: [{driverUri: String, bid: Number, driverName: String, accepted: Boolean}],
		pickedUp: Date
	}, { collection : 'deliveries' })

	DeliverySchema.statics.get = (flowerShopId, cb)->
		@find({"flowerShopId": flowerShopId}).exec cb

	DeliverySchema.statics.addBid = (delivery_id, data, cb)->
		delivery_id = new ObjectId(delivery_id)
		@findOne({"_id": delivery_id}).exec (err, delivery)=>
			return cb err if err?
			return cb {failed: true} if not delivery?
			foundBid = false
			delivery.bids = [] if not delivery.bids?
			for bid in delivery.bids
				if bid.driverUri is data.driverUri
					bid.driverName = data.driverName
					bid.bid = data.bid
					foundBid = true
			if not foundBid
				console.log "Added Bid: " + data
				delivery.bids.push(data)
				console.log delivery

			delivery.save (err)=>
				return cb err if err?
				cb null, delivery

	DeliverySchema.statics.acceptBid = (delivery_id, bid_id, cb)->
		delivery_id = new ObjectId(delivery_id)
		@findOne({"_id": delivery_id}).exec (err, delivery)=>
			return cb err if err?
			return cb {failed: true} if not delivery?
			return cb {failed: true} if not delivery.bids?

			for bid in delivery.bids
				if bid_id is "#{bid._id}"
					acceptBid = bid
			deliveryBids = [acceptBid]
			acceptBid.accepted = true

			delivery.save (err)=>
				return cb err if err?
				cb null, delivery

	DeliverySchema.statics.pickedUp = (delivery_id, cb)->
		delivery_id = new ObjectId(delivery_id)
		@update({"_id": delivery_id}, {pickedUp: new Date()}).exec (err)=>
			@findOne({"_id": delivery_id}).exec cb


	Delivery = db.model "Delivery", DeliverySchema