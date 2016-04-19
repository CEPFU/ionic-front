angular.module 'starter.services', ['ionic.service.core', 'starter.config']

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

.service 'ProfileService', ($localStorage, RestService) ->
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

  @deleteProfile = (profile) ->
    delete @profileData.profiles[profile.id]
    @persist()
    RestService.deleteProfile profile


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

.service 'RestService', ($rootScope, $ionicUser, $http,
filterFilter, $ionicCoreSettings, ConfigService) ->

  @endpointUrl = ConfigService.api.mainUrl
  @getApiUrl = (target) ->
    @endpointUrl + ConfigService.api.endpoints[target].url

  @getUser = () ->
    user = Ionic.User.current()
    if not user.id
      user.id = Ionic.User.anonymousId()
      user.save()
    user

  @findNearbyStations = (location, callback, limit=3) ->
    url = @getApiUrl 'nearby'
    $http.post(url + limit,
      latitude: location.latlng.lat
      longitude: location.latlng.lng
    ).then(
      (succ) ->
        console.log 'Success:', succ
        locations = succ.data
        if callback?
          callback locations
      ,
      (fail) ->
        console.log 'Failure:', fail
    )

  # Copies the specified properties into a new object (shallow?)
  @selectiveCopy = (obj, properties) ->
    newObj = {}
    for prop in properties
      newObj[prop] = obj[prop]
    newObj

  @findJavaClass = (inputConfig, inputValue) ->
    if inputConfig.javaClass?
      inputConfig.javaClass
    else
      if inputConfig.options?
        inputConfig.options[inputValue.value]?.javaClass

  @getValue = (config, input) ->
    value = input.value
    if config.valueType?
      switch config.valueType
        when 'int'
          value = parseInt value
        when 'float'
          value = parseFloat value
    value

  @transformLocation = (location) ->
    accuracy: location.accuracy
    position:
      latitude: location.latlng.lat
      longitude: location.latlng.lng
    timestamp: location.timestamp


  @transformProfile = (profile) ->
    newProfile = @selectiveCopy profile, ['name', 'id']

    newProfile.userId = @getUser().id
    newProfile.location = @transformLocation profile.location
    newProfile.appId = $ionicCoreSettings.get('app_id')

    rule =
      '@class': 'JSONAnd'
      ofOperands: []

    for prop in (profile.properties ? [])
      config = ConfigService.profile.properties[prop.name]

      operand = {
        '@class': 'JSONMatchToStation'
        toStation: profile.station.locationId # TODO: Find new format?!
      }

      # console.log 'Prop:', prop
      # console.log 'Config:', config

      switch config.javaStructure.type
        when 'attributeToObject'
          classFrom = config.javaStructure.classFrom
          valueFrom = config.javaStructure.valueFrom
          javaClass = @findJavaClass config.inputs[classFrom],
            prop.inputs[classFrom]
          value = @getValue config.inputs[valueFrom], prop.inputs[valueFrom]
          operand.matchOperator = {
            '@class': javaClass
            attribute: prop.name
            toObject: value
          }

      rule.ofOperands.push operand

    newProfile.profile =
      rule: rule

    newProfile

  @sendProfile = (profile) ->
    url = @getApiUrl 'profile'

    payload = @transformProfile profile

    # console.log 'API URL:', url
    # console.log 'Payload:', payload
    # console.log 'JSON Payload:', JSON.stringify payload

    $http.post url, payload

    null

  @deleteProfile = (profile) ->
    url = @getApiUrl 'profile'
    # TODO: simplify this, we only really need the user and profile ID!
    payload = transformProfile profile
    $http.delete url, payload

  null
