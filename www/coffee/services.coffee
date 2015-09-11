angular.module 'starter.services', ['ionic.service.core']

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

    @map.on 'locationfound', @applyListeners

  @applyListeners = (location) =>
    for listener in @listeners
      listener(location)

  @registerListener = (listener) ->
    @listeners.push(listener)

  @popListener = (idx = -1) ->
    @listeners.splice(idx, 1)

  # Copies the relevant properties from the leaflet location
  @simpleLocation = (location) ->
    propertiesToCopy = [
      'accuracy', 'bounds', 'latlng', 'timestamp'
    ]

    simple = {}
    for prop in propertiesToCopy
      simple[prop] = location[prop]

    simple

  @setView = (location) ->
    zoom = if location.accuracy? then Math.round(location.accuracy / 2) else 16
    @map.setView location.latlng, zoom

  # Adds a pin at the specified location and adds an optional popup
  @addPin = (location, popup) =>
    marker = L.marker location.latlng
    .addTo @map

    if popup?
      marker.bindPopup popup
      .openPopup()

  @locate = (popup, circle = false, options = {setView: true, maxZoom: 16}) ->
    @registerListener (location) =>
      radius = location.accuracy / 2

      popupText = if popup? then popup(location) else null
      @addPin location, popupText

      if circle
        L.circle location.latlng, radius
          .addTo @map

      @popListener()

    @map.locate options

  null

.service 'ProfileService', ($localStorage) ->
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
      id: @profileData.lastId ? 0
    }
    @putProfile newProfile
    newProfile

  @profileData = $localStorage.getObject 'profiles'
  if not @profileData?
    @profileData =
      lastId: 0
      profiles: {}
    @persist @profileData

  null

.service 'LocationService', () ->
  @currentLocation = undefined
  null

.service 'RestService', ($ionicUser, $http) ->

  @endpointUrl = 'http://localhost:8080/'
  @getApiUrl = (target) -> @endpointUrl + target

  @getUser = () ->
    user = $ionicUser.get()
    if not user.user_id
      user.user_id = $ionicUser.generateGUID()
    user

  @sendProfile = (profile) ->
    console.log 'Sending profile to backend:', profile
    url = @getApiUrl 'profile'
    payload = {
      user: @getUser()
    }

    console.log 'API URL:', url
    console.log 'Payload:', payload

    null


  null
