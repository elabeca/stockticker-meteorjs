Meteor.startup ->
  $('#quote-carousel .carousel-inner .item:first').addClass('active')
  $('.carousel').carousel()
  setInterval refreshStocks, 300000

Template.button_bar.events =
  'keyup #input-symbol': (e, t) ->
    if e.type is 'keyup' and e.which is 13
      addStock t.find('#input-symbol').value
      t.find('#input-symbol').value = ""
  'click #btn-add': (e, t) ->
    addStock t.find('#input-symbol').value
    t.find('#input-symbol').value = ""
  'click #btn-delete': (e, t) -> removeStocks()
  'click #btn-refresh': (e, t) -> refreshStocks()

Template.quote_list.events =
  'click .remove': (e, t) -> removeStock @_id
  'change input.select': (e, t) ->
    selected = Quotes.findOne({ _id: @_id }).selected
    checked = if selected is 'checked' then '' else 'checked'
    Quotes.update(@_id, { $set: { 'selected': checked } })

Template.quote_list.quotes =
  Template.quote_carousel.quotes = -> Quotes.find({}).fetch()

Template.quote_carousel.rendered = ->
  oldIndex = $('#quote-carousel .carousel-inner .active').index()
  if oldIndex > 0
    $('#quote-carousel .carousel-inner .item')
      .nextAll()
      .eq(oldIndex - 1)
      .addClass('active')
  else
    $('#quote-carousel .carousel-inner .item:first').addClass('active')

addStock = (symbol) ->
  refreshStocks symbol unless Quotes.find({ symbol: symbol }).count()
	
removeStock = (id) -> Quotes.remove id
	
removeStocks = ->
  _.each Quotes.find({selected: 'checked'}).fetch(), (stock) ->
    Quotes.remove stock._id
	
refreshStocks = (symbol) -> Meteor.call 'getQuotes', symbol