fs = Npm.require 'fs'

Meteor.methods
	getQuotes: (symbol) ->
		getQuotesFromServer(symbol).forEach (stock) ->
			Quotes.remove symbol: stock.symbol
			Quotes.insert stock
	
getQuotesFromServer = (symbol, options) ->
	stocks = "AAPL+GOOG+MSFT"
	obj = []
	i = 0
	if symbol then stocks = symbol else stocks = _.pluck(Quotes.find({}, { symbol: 1, _id: 0 }).fetch(), "symbol").join "+"
	options or= {}
	options.filename or= 'quotes.txt'
	options.hostname or= 'download.finance.yahoo.com'
	options.path or= "/d/quotes.csv?s=#{stocks}&f=snabl1p0"
	console.log "==> Calling host #{options.hostname}#{options.path}"
	url = "http://#{options.hostname}#{options.path}" 
	res = Meteor.http.get url
	console.log "==> Received:\n#{res.content}"
	res.content.split('\n').forEach (line) ->
		arr = line.toString().trim().split ','
		if arr[0]
			symbol = arr[0].replace /\"/g, ''
			name = arr[1].replace /\"/g, ''
			obj.push { id: i++, symbol: symbol, name: name, ask: arr[2], bid: arr[3], last_trade: arr[4], previous_close: arr[5] }
	obj