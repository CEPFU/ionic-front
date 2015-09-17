angular.module('starter.controllers', ['angular.filter', 'starter.services'])

.controller 'AppCtrl', ($rootScope, $http) ->
  $http.get('json/config.json').success (data) ->
    $rootScope.config = data

  $rootScope.asList = (object) ->
    res = []
    for name, prop of object
      res.push(prop)
    res

  null

.controller 'ProfilesCtrl', ($scope, ProfileService, $state) ->
  $scope.profiles = ProfileService.getProfiles()
  @newProfile = () ->
    np = ProfileService.newProfile()
    $scope.profiles = ProfileService.getProfiles()
    $state.go 'app.profile', {profileId: np.id}

  null

.controller 'SingleProfileCtrl', ($rootScope, $scope, $stateParams,
    ProfileService, LocationService, RestService, filterFilter) ->
  $scope.profile = ProfileService.getProfile $stateParams.profileId
  LocationService.currentLocation = $scope.profile.location

  $scope.locationDescription = () ->
    if $scope.profile?.location?
      "(#{$scope.profile.location.latlng.lat},
        #{$scope.profile.location.latlng.lng})"
    else
      null

  # When we come back from the location page
  $scope.$watch (() -> ProfileService.currentLocation), (newLocation) ->
    if newLocation?
      ProfileService.currentLocation = undefined
      LocationService.currentLocation = newLocation
      $scope.profile.location = newLocation

  # On exit: Persist changes to profile
  $scope.$on '$destroy', ($destroy) ->
    ProfileService.putProfile $scope.profile
    ProfileService.persist()
    LocationService.location = undefined

    RestService.sendProfile $scope.profile

  $scope.addProperty = () ->
    if not $scope.profile.properties?
      $scope.profile.properties = []
    $scope.profile.properties.push {}

  $scope.getClasses = (input) ->
    switch input.type
      when 'select'
        'item-select'
      when 'range'
        'range range-positive'

  null


.controller 'LocationCtrl',
  ($scope, MapService, LocationService, ProfileService, $ionicHistory) ->
    $scope.noLocation = true
    $scope.locateMe = () -> MapService.locate()

    @setLocation = (location) =>
      @location = location
      $scope.noLocation = not @location?

    MapService.init 'map'
    MapService.registerListener (location) =>
      @setLocation MapService.simpleLocation location
      $scope.$apply () -> $scope.noLocation = not @location?

    if LocationService.currentLocation?
      @setLocation LocationService.currentLocation
      MapService.setView @location
      MapService.addPin @location, "Selected location"
    else
      MapService.locate (loc) -> "You are here."

    $scope.selectLocation = () =>
      if @location?
        console.log 'Setting location:', @location
        ProfileService.currentLocation = @location
        $ionicHistory.goBack()
      else
        console.log 'Error: no location found'

    null
