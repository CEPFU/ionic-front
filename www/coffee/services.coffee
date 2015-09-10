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

.service 'ProfileService', (filterFilter, $localStorage, $rootScope) ->
  @newLocation = undefined

  @persist = (profileData) ->
    if not profileData?
      profileData = @profileData
    console.log 'Persisting:', JSON.stringify profileData
    $localStorage.setObject 'profiles', profileData

  @getProfiles = () -> @profileData.profiles
  @getProfile = (id) -> @profileData.profiles[id]
  @putProfile = (id, profile) -> @profileData.profiles[id] = profile
  @putProfile = (profile) -> @profileData.profiles[profile.id] = profile
  @newProfile = () ->
    @profileData.lastId += 1
    newProfile = {
      name: 'New Profile'
      id: @profileData.lastId
    }
    @putProfile newProfile
    newProfile

  @profileData = $localStorage.getObject 'profiles'
  if not @profileData?
    @profileData =
      lastId: 1
      profiles:
        '0':
          name: "Profile 1"
          id: 0
          location: 12
        '1':
          name: "Profile 2"
          id: 1

    @persist @profileData

  null

.service 'LocationService', ($http, filterFilter) ->
  locationPromise = undefined
  @getLocations = () ->
    if not locationPromise?
      locationPromise = $http.get('http://localhost:8080/location.json')
    locationPromise

  @getLocation = (locations, id) ->
    filtered = filterFilter locations, (loc) ->
      loc.locationId == id
    filtered[0]

  @currentLocation = undefined
  null
