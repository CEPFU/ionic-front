angular.module 'starter.services', []

.service 'MapService', () ->
  @map = null
  @listeners = []

  @init = (cssId) =>
    @map = L.map cssId

    L.tileLayer("https://api.tiles.mapbox.com/v4/{id}\
      /{z}/{x}/{y}.png?access_token={accessToken}", {
      attribution: """Map data &copy;
        <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
        <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
        Imagery © <a href="http://mapbox.com">Mapbox</a>"""
      maxZoom: 18
      id: 'coolbox4life.dfc12b44'
      accessToken: "pk.eyJ1IjoiY29vbGJveDRsaWZlIiwiYSI6ImY2Zjk2YmQ1ZjMyYWM2ZDZk\
      YjI2OWIzY2U3YzMwY2NhIn0.WGZ5HU-CIlNshi1UVm4z-g"
    })
    .addTo @map

    @map.on 'locationfound', (location) =>
      for listener in @listeners
        listener(location)

  @registerListener = (listener) ->
    @listeners.push(listener)

  @locate = (popup, circle = false, options = {setView: true, maxZoom: 16}) ->
    @map.locate options

    @map.on 'locationfound', (location) =>
      radius = location.accuracy / 2
      marker = L.marker location.latlng
        .addTo @map

      if popup?
        marker.bindPopup popup(location)
        .openPopup()
      if circle
        L.circle location.latlng, radius
          .addTo @map
      null

  null
