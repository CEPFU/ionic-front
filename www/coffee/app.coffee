# Ionic Starter App
# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.controllers' is found in controllers.js

angular.module('starter', [
  'ionic'
  'starter.controllers'
])

.run(($ionicPlatform) ->
  $ionicPlatform.ready ->

    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true

    # org.apache.cordova.statusbar required
    StatusBar.styleDefault() if window.StatusBar
)

.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state('app',
      url: '/app'
      abstract: true
      templateUrl: 'templates/menu.html'
      controller: 'AppCtrl'
    )

    .state('app.profiles',
      url: '/profiles'
      views:
        menuContent:
          templateUrl: 'templates/profiles.html'
          controller: 'ProfilesCtrl'
    )

    .state('app.profile',
      url: '/profiles/:profileId'
      views:
        menuContent:
          templateUrl: 'templates/profile.html'
          controller: 'SingleProfileCtrl'
    )

    .state('app.locations',
      url: '/locations',
      views:
        menuContent:
          templateUrl: 'templates/locations.html'
          controller: 'LocationsCtrl'
    )

  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise '/app/profiles'
