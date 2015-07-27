(function() {
  angular.module('starter.controllers', ['angular.filter']).controller('AppCtrl', function($scope, $ionicModal, $timeout, $http) {
    $scope.loginData = {};
    $ionicModal.fromTemplateUrl('templates/login.html', {
      scope: $scope
    }).then(function(modal) {
      return $scope.modal = modal;
    });
    $scope.closeLogin = function() {
      return $scope.modal.hide();
    };
    $scope.login = function() {
      return $scope.modal.show();
    };
    $scope.doLogin = function() {
      console.log('Doing login', $scope.loginData);
      return $timeout((function() {
        return $scope.closeLogin();
      }), 1000);
    };
    return $http.get('http://localhost:8080/location').success(function(data) {
      return $scope.locations = data;
    });
  }).controller('LocationsCtrl', function($scope) {
    return console.log('');
  }).controller('SingleLocationCtrl', function($scope, $stateParams, filterFilter) {
    var filtered, map, marker;
    $scope.locationId = parseInt($stateParams.locationId);
    filtered = filterFilter($scope.locations, function(loc) {
      return loc.locationId === $scope.locationId;
    });
    $scope.location = filtered[0];
    $scope.latlong = [$scope.location.locationPosition.latitude, $scope.location.locationPosition.longitude];
    map = L.map('map').setView($scope.latlong, 10);
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
      maxZoom: 18,
      id: 'coolbox4life.dfc12b44',
      accessToken: 'pk.eyJ1IjoiY29vbGJveDRsaWZlIiwiYSI6ImY2Zjk2YmQ1ZjMyYWM2ZDZkYjI2OWIzY2U3YzMwY2NhIn0.WGZ5HU-CIlNshi1UVm4z-g'
    }).addTo(map);
    marker = L.marker($scope.latlong).addTo(map);
    return null;
  });

}).call(this);
