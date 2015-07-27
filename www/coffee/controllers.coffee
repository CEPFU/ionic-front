angular.module('starter.controllers', ['angular.filter'])

.controller 'AppCtrl', ($scope, $ionicModal, $timeout, $http) ->
  # Form data for the login modal 1
  $scope.loginData = {}

  # Create the login modal that we will use later
  $ionicModal.fromTemplateUrl('templates/login.html', scope: $scope).then (modal) ->
    $scope.modal = modal

  # Triggered in the login modal to close it
  $scope.closeLogin = ->
    $scope.modal.hide()

  # Open the login modal
  $scope.login = ->
    $scope.modal.show()

  # Perform the login action when the user submits the login form
  $scope.doLogin = ->
    console.log 'Doing login', $scope.loginData
    # Simulate a login delay. Remove this and replace with your login
    # code if using a login system
    $timeout (-> $scope.closeLogin()), 1000

  $http.get('http://localhost:8080/location').success (data) ->
    $scope.locations = data


.controller 'LocationsCtrl', ($scope) ->
  console.log ''

.controller 'SingleLocationCtrl', ($scope, $stateParams, filterFilter) ->
  $scope.locationId = parseInt $stateParams.locationId
  filtered = filterFilter $scope.locations, (loc) ->
    loc.locationId == $scope.locationId
  $scope.location = filtered[0]
  $scope.latlong = [$scope.location.locationPosition.latitude, $scope.location.locationPosition.longitude]

  map = L
  .map 'map'
  .setView $scope.latlong, 10
  L.tileLayer 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}',
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
    maxZoom: 18,
    id: 'coolbox4life.dfc12b44',
    accessToken: 'pk.eyJ1IjoiY29vbGJveDRsaWZlIiwiYSI6ImY2Zjk2YmQ1ZjMyYWM2ZDZkYjI2OWIzY2U3YzMwY2NhIn0.WGZ5HU-CIlNshi1UVm4z-g'
  .addTo(map);

  marker = L.marker $scope.latlong
  .addTo map

  return null
