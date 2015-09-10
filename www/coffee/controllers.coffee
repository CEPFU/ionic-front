angular.module('starter.controllers', ['angular.filter', 'starter.services'])

.controller 'AppCtrl', () ->
  null

.controller 'LocationsCtrl', ($scope, LocationService, ProfileService) ->
  LocationService.getLocations().success (data) ->
    $scope.locations = data

  @current = LocationService.currentLocation
  $scope.$watch (() => @current), (newVal) ->
    ProfileService.currentLocation = newVal

  null

.controller 'ProfilesCtrl', ($scope, ProfileService, $state) ->
  $scope.profiles = ProfileService.getProfiles()
  @newProfile = () ->
    np = ProfileService.newProfile()
    $scope.profiles = ProfileService.getProfiles()
    $state.go 'app.profile', {profileId: np.id}

  null

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


.controller 'LocationCtrl', ($scope, MapService) ->
  MapService.init 'map'
  MapService.locate (loc) -> "You are within #{loc.accuracy / 2}
    meters of this point"

  null
