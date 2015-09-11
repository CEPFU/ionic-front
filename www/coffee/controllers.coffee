angular.module('starter.controllers', ['angular.filter', 'starter.services'])

.controller 'AppCtrl', ($rootScope, $http) ->
  $http.get('config.json').success (data) ->
    $rootScope.config = data

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

  $scope.inputsForProperty = (prop) ->
    result = []

    props = $rootScope.config.profile.properties

    filtered = filterFilter props, (current) -> current.name == prop.name
    propertyConfig = filtered[0]
    console.log 'Property Config:', propertyConfig

    switch propertyConfig.input.type
      when 'range'
        result.push
          label: 'Minimum'
          type: 'range'
          iconBefore: 'ion-ios-sunny-outline'
          iconAfter: 'ion-ios-snowy'
        result.push
          label: 'Maximum'
          type: 'range'
          iconBefore: 'ion-ios-sunny-outline'
          iconAfter: 'ion-ios-snowy'


    result

  return null


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
