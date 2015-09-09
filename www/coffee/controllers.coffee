angular.module('starter.controllers', ['angular.filter'])

.factory 'ProfilesFactory', (filterFilter) ->
  profiles = [
    name: "Profile 1"
    id: 1
    location: 12
  ,
    name: "Profile 2"
    id: 5
  ]

  {
    profiles: profiles
    getProfile: (id) ->
      filtered = filterFilter profiles, (prof) ->
        prof.id == id
      filtered[0]
  }

.service 'LocationService', ($http, filterFilter) ->
  locationPromise = undefined
  this.getLocations = () ->
    if not locationPromise?
      locationPromise = $http.get('http://localhost:8080/location')
    locationPromise

  this.getLocation = (locations, id) ->
    filtered = filterFilter locations, (loc) ->
      loc.locationId == id
    filtered[0]

  this.currentLocation = undefined
  null

.controller 'AppCtrl', () ->
  null

.controller 'LocationsCtrl', ($scope, LocationService) ->
  LocationService.getLocations().success (data) ->
    $scope.locations = data

  this.current = LocationService.currentLocation
  $scope.$watch (() => this.current), (newVal) ->
    LocationService.currentLocation = newVal

  null

.controller 'ProfilesCtrl', ($scope, ProfilesFactory, LocationService) ->
  $scope.profiles = ProfilesFactory.profiles
  return null

.controller 'SingleProfileCtrl', ($scope, $stateParams, ProfilesFactory, LocationService) ->
  $scope.profile = ProfilesFactory.getProfile (parseInt $stateParams.profileId)

  LocationService.getLocations().success (data) ->
    $scope.locations = data
    if LocationService.currentLocation?
      $scope.profile.location = LocationService.currentLocation

    $scope.location = LocationService.getLocation $scope.locations, $scope.profile.location
    LocationService.currentLocation = $scope?.location?.locationId

  update = (newLocation) ->
    if newLocation?
      LocationService.currentLocation = undefined
      $scope.profile.location = newLocation
      $scope.location = LocationService.getLocation $scope.locations, $scope.profile.location

  $scope.$watch (() -> LocationService.currentLocation), update

  return null
