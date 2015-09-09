angular.module('starter.controllers', ['angular.filter'])

.service 'ProfileService', (filterFilter, $localStorage, $rootScope) ->
  @newLocation = undefined

  @persist = (profiles) ->
    if not profiles?
      profiles = @profiles
    console.log 'Persisting:', JSON.stringify profiles
    $localStorage.setObject 'profiles', profiles

  @getProfile = (id) -> @profiles[id]
  @putProfile = (id, profile) -> @profiles[id] = profile
  @putProfile = (profile) -> @profiles[profile.id] = profile

  @profiles = $localStorage.getObject 'profiles'
  if not @profiles?
    @profiles =
      '1':
        name: "Profile 1"
        id: 1
        location: 12
      '5':
        name: "Profile 2"
        id: 5
    @persist @profiles

  null

.service 'LocationService', ($http, filterFilter) ->
  locationPromise = undefined
  @getLocations = () ->
    if not locationPromise?
      locationPromise = $http.get('http://localhost:8080/location')
    locationPromise

  @getLocation = (locations, id) ->
    filtered = filterFilter locations, (loc) ->
      loc.locationId == id
    filtered[0]

  @currentLocation = undefined
  null

.controller 'AppCtrl', () ->
  null

.controller 'LocationsCtrl', ($scope, LocationService, ProfileService) ->
  LocationService.getLocations().success (data) ->
    $scope.locations = data

  @current = LocationService.currentLocation
  $scope.$watch (() => @current), (newVal) ->
    ProfileService.currentLocation = newVal

  null

.controller 'ProfilesCtrl', ($scope, ProfileService, LocationService) ->
  $scope.profiles = ProfileService.profiles
  return null

.controller 'SingleProfileCtrl',
($scope, $stateParams, ProfileService, LocationService) ->
  $scope.profile = ProfileService.getProfile $stateParams.profileId

  LocationService.getLocations().success (data) ->
    $scope.locations = data
    if ProfileService.currentLocation?
      $scope.profile.location = ProfileService.currentLocation

    $scope.location =
      LocationService.getLocation $scope.locations, $scope.profile.location
    LocationService.currentLocation = $scope?.location?.locationId

  update = (newLocation) ->
    if newLocation?
      ProfileService.currentLocation = undefined
      LocationService.currentLocation = newLocation
      $scope.profile.location = newLocation
      $scope.location =
        LocationService.getLocation $scope.locations, $scope.profile.location

  $scope.$watch (() -> ProfileService.currentLocation), update

  $scope.$on '$destroy', ($destroy) ->
    ProfileService.putProfile $scope.profile
    ProfileService.persist()

  return null
