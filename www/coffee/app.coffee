# Ionic Starter App
angular.module('starter', [
  'ionic'
  'starter.controllers'
  'starter.directives'
  'starter.services'
  'ionic.service.core'
  'ionic.service.push'
])

.filter 'titleCase', ->
  (input) ->
    words = input.split(' ')
    i = 0
    while i < words.length
      words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
      i++
    words.join ' '


.factory '$localStorage', ['$window', ($window) ->
  return {
    set: (key, value) ->
      $window.localStorage[key] = value
    get: (key, defaultValue) ->
      $window.localStorage[key] || defaultValue
    setObject: (key, value) ->
      $window.localStorage[key] = JSON.stringify value
    getObject: (key) ->
      value = $window.localStorage[key]
      if not value? or value in ['undefined', 'null']
        undefined
      else
        JSON.parse value
}]

.run(($ionicPlatform, $ionicUser, $rootScope, $http) ->
  $ionicPlatform.ready ->

    # Hide the accessory bar by default
    # (remove this to show the accessory bar above the keyboard for form inputs)
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true

    # org.apache.cordova.statusbar required
    StatusBar.styleDefault() if window.StatusBar

    Ionic.io()

    user = Ionic.User.current()
    if not user.id
      user.id = Ionic.User.anonymousId()
      user.save().then(
        (success) ->
          console.log 'Success:', success
      ,
        (failure) ->
          console.log 'Failure', failure
      )
    push = new Ionic.Push(
      'debug': true
      'onNotification': (notification) ->
        console.log notification
        return
      'onRegister': (data) ->
        console.log 'Device token (X):', data.token
        try
          push.addTokenToUser user
        catch error
          console.log 'Error while adding token to user:', error
        console.log 'User:', user
        return
    )

    try
      push.register()
    catch error
      console.log 'Error while registering for push:', error

    $rootScope.$on '$cordovaPush:tokenReceived', (event, data) ->
      console.log 'Got token', data.token, data.platform
      # Do something with the token
      return
)

.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state 'app',
      url: '/app'
      abstract: true
      templateUrl: 'templates/menu.html'
      controller: 'AppCtrl'

    .state 'app.profiles',
      url: '/profiles'
      views:
        menuContent:
          templateUrl: 'templates/profiles.html'
          controller: 'ProfilesCtrl'

    .state 'app.profile',
      url: '/profiles/:profileId'
      views:
        menuContent:
          templateUrl: 'templates/profile.html'
          controller: 'SingleProfileCtrl'

    .state 'app.selectLocation',
      url: '/location',
      views:
        menuContent:
          templateUrl: 'templates/location.html'
          controller: 'LocationCtrl'

  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise '/app/profiles'
