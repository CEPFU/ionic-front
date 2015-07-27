(function() {
  angular.module('starter', ['ionic', 'starter.controllers']).run(function($ionicPlatform) {
    return $ionicPlatform.ready(function() {
      if (window.cordova && window.cordova.plugins.Keyboard) {
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
      if (window.StatusBar) {
        return StatusBar.styleDefault();
      }
    });
  }).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('app', {
      url: '/app',
      abstract: true,
      templateUrl: 'templates/menu.html',
      controller: 'AppCtrl'
    }).state('app.search', {
      url: '/search',
      views: {
        menuContent: {
          templateUrl: 'templates/search.html'
        }
      }
    }).state('app.browse', {
      url: '/browse',
      views: {
        menuContent: {
          templateUrl: 'templates/browse.html'
        }
      }
    }).state('app.locations', {
      url: '/locations',
      views: {
        menuContent: {
          templateUrl: 'templates/locations.html',
          controller: 'LocationsCtrl'
        }
      }
    }).state('app.single', {
      url: '/locations/:locationId',
      views: {
        menuContent: {
          templateUrl: 'templates/location.html',
          controller: 'SingleLocationCtrl'
        }
      }
    });
    return $urlRouterProvider.otherwise('/app/locations');
  });

}).call(this);
