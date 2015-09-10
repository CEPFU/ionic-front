angular.module('starter.controllers', ['angular.filter', 'starter.services'])

.controller 'AppCtrl', () ->
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
  LocationService.currentLocation = $scope.profile.location

  $scope.locationDescription = () ->
    if $scope.profile?.location?
      "(#{$scope.profile.location.latitude},
        #{$scope.profile.location.longitude})"
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

  return null


.controller 'LocationCtrl',
  ($scope, MapService, LocationService, ProfileService) ->
    $scope.hasLocation = () => @location?
    $scope.locateMe = () -> MapService.locate()

    MapService.init 'map'
    MapService.registerListener (location) =>
      @location = MapService.simpleLocation location

    if LocationService.currentLocation?
      @location = LocationService.currentLocation
      MapService.setView @location
      MapService.addPin @location, "Selected location"
    else
      MapService.locate (loc) -> "You are here."

    $scope.selectLocation = () =>
      if @location?
        console.log 'Setting location:', @location
        ProfileService.currentLocation = @location
      else
        console.log 'Error: no location found'

    null
