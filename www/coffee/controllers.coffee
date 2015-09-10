angular.module('starter.controllers', ['angular.filter'])

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
          id: 1
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
