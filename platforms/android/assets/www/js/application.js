(function() {
  angular.module('starter', ['ionic', 'starter.controllers', 'starter.directives', 'starter.services', 'ionic.service.core', 'ionic.service.push']).filter('titleCase', function() {
    return function(input) {
      var i, words;
      words = input.split(' ');
      i = 0;
      while (i < words.length) {
        words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1);
        i++;
      }
      return words.join(' ');
    };
  }).factory('$localStorage', [
    '$window', function($window) {
      return {
        set: function(key, value) {
          return $window.localStorage[key] = value;
        },
        get: function(key, defaultValue) {
          return $window.localStorage[key] || defaultValue;
        },
        setObject: function(key, value) {
          return $window.localStorage[key] = JSON.stringify(value);
        },
        getObject: function(key) {
          var value;
          value = $window.localStorage[key];
          if ((value == null) || (value === 'undefined' || value === 'null')) {
            return void 0;
          } else {
            return JSON.parse(value);
          }
        }
      };
    }
  ]).run(function($ionicPlatform, $ionicUser, $rootScope, $http) {
    return $ionicPlatform.ready(function() {
      var error, error1, push;
      if (window.cordova && window.cordova.plugins.Keyboard) {
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
      if (window.StatusBar) {
        StatusBar.styleDefault();
      }
      Ionic.io();
      push = new Ionic.Push({
        'debug': true,
        'onNotification': function(notification) {
          var payload;
          payload = notification['_raw'].text;
          alert(payload);
        },
        'onRegister': function(data) {
          var error, error1, user;
          console.log('Device token (X):', data.token);
          user = $ionicUser.get();
          if (!user.user_id) {
            user.user_id = $ionicUser.generateGUID();
          }
          try {
            push.addTokenToUser($ionicUser);
          } catch (error1) {
            error = error1;
            console.log('Error while adding token to user:', error);
          }
          console.log('User:', user);
        }
      });
      window.push = push;
      try {
        push.register();
      } catch (error1) {
        error = error1;
        console.log('Error while registering for push:', error);
      }
      return $rootScope.$on('$cordovaPush:tokenReceived', function(event, data) {
        console.log('Got token', data.token, data.platform);
      });
    });
  }).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('app', {
      url: '/app',
      abstract: true,
      templateUrl: 'templates/menu.html',
      controller: 'AppCtrl'
    }).state('app.profiles', {
      url: '/profiles',
      views: {
        menuContent: {
          templateUrl: 'templates/profiles.html',
          controller: 'ProfilesCtrl'
        }
      }
    }).state('app.profile', {
      url: '/profiles/:profileId',
      views: {
        menuContent: {
          templateUrl: 'templates/profile.html',
          controller: 'SingleProfileCtrl'
        }
      }
    }).state('app.selectLocation', {
      url: '/location',
      views: {
        menuContent: {
          templateUrl: 'templates/location.html',
          controller: 'LocationCtrl'
        }
      }
    });
    return $urlRouterProvider.otherwise('/app/profiles');
  });

}).call(this);

(function() {
  angular.module('starter.controllers', ['angular.filter', 'starter.services']).controller('AppCtrl', function($rootScope, $http) {
    $http.get('json/config.json').success(function(data) {
      return $rootScope.config = data;
    });
    $rootScope.asList = function(object) {
      var name, prop, res;
      res = [];
      for (name in object) {
        prop = object[name];
        res.push(prop);
      }
      return res;
    };
    return null;
  }).controller('ProfilesCtrl', function($scope, ProfileService, $state) {
    $scope.profiles = ProfileService.getProfiles();
    this.newProfile = function() {
      var np;
      np = ProfileService.newProfile();
      $scope.profiles = ProfileService.getProfiles();
      return $state.go('app.profile', {
        profileId: np.id
      });
    };
    return null;
  }).controller('SingleProfileCtrl', function($rootScope, $scope, $stateParams, ProfileService, LocationService, RestService, filterFilter) {
    $scope.profile = ProfileService.getProfile($stateParams.profileId);
    LocationService.currentLocation = $scope.profile.location;
    $scope.locationDescription = function() {
      var ref;
      if (((ref = $scope.profile) != null ? ref.location : void 0) != null) {
        return "(" + $scope.profile.location.latlng.lat + ", " + $scope.profile.location.latlng.lng + ")";
      } else {
        return null;
      }
    };
    $scope.$watch((function() {
      return ProfileService.currentLocation;
    }), function(newLocation) {
      if (newLocation != null) {
        ProfileService.currentLocation = void 0;
        LocationService.currentLocation = newLocation;
        return $scope.profile.location = newLocation;
      }
    });
    $scope.$on('$destroy', function($destroy) {
      ProfileService.putProfile($scope.profile);
      ProfileService.persist();
      LocationService.location = void 0;
      return RestService.sendProfile($scope.profile);
    });
    $scope.addProperty = function() {
      if ($scope.profile.properties == null) {
        $scope.profile.properties = [];
      }
      return $scope.profile.properties.push({});
    };
    $scope.getClasses = function(input) {
      switch (input.type) {
        case 'select':
          return 'item-select';
        case 'range':
          return 'range range-positive';
      }
    };
    return null;
  }).controller('LocationCtrl', function($scope, MapService, LocationService, ProfileService, $ionicHistory) {
    $scope.noLocation = true;
    $scope.locateMe = function() {
      return MapService.locate();
    };
    this.setLocation = (function(_this) {
      return function(location) {
        _this.location = location;
        return $scope.noLocation = _this.location == null;
      };
    })(this);
    MapService.init('map');
    MapService.registerListener((function(_this) {
      return function(location) {
        _this.setLocation(MapService.simpleLocation(location));
        return $scope.$apply(function() {
          return $scope.noLocation = this.location == null;
        });
      };
    })(this));
    if (LocationService.currentLocation != null) {
      this.setLocation(LocationService.currentLocation);
      MapService.setView(this.location);
      MapService.addPin(this.location, "Selected location");
    } else {
      MapService.locate(function(loc) {
        return "You are here.";
      });
    }
    $scope.selectLocation = (function(_this) {
      return function() {
        if (_this.location != null) {
          console.log('Setting location:', _this.location);
          ProfileService.currentLocation = _this.location;
          return $ionicHistory.goBack();
        } else {
          return console.log('Error: no location found');
        }
      };
    })(this);
    return null;
  });

}).call(this);

(function() {
  angular.module('starter.directives', []).directive('profileInput', function() {
    return {
      restrict: 'E',
      scope: {
        input: '=',
        profile: '=',
        property: '='
      },
      link: function(scope, element, attrs) {
        return scope.getContentUrl = function() {
          return "templates/inputs/" + scope.input.type + ".html";
        };
      },
      template: '<div ng-include="getContentUrl()"></div>',
      controllerAs: 'inputCtrl',
      controller: function($rootScope, $scope) {
        return $scope.asList = $rootScope.asList;
      }
    };
  });

}).call(this);

(function() {
  angular.module('starter.services', ['ionic.service.core']).service('MapService', function() {
    this.map = null;
    this.listeners = [];
    this.init = (function(_this) {
      return function(cssId) {
        _this.map = L.map(cssId);
        L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
          attribution: "Map data &copy;\n<a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors,\n<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>,\nImagery © <a href=\"http://mapbox.com\">Mapbox</a>",
          maxZoom: 18,
          id: 'coolbox4life.dfc12b44',
          accessToken: "pk.eyJ1IjoiY29vbGJveDRsaWZlIiwiYSI6ImY2Zjk2YmQ1ZjMyYWM2ZDZkYjI2OWIzY2U3YzMwY2NhIn0.WGZ5HU-CIlNshi1UVm4z-g"
        }).addTo(_this.map);
        return _this.map.on('locationfound', _this.applyListeners);
      };
    })(this);
    this.applyListeners = (function(_this) {
      return function(location) {
        var i, len, listener, ref, results;
        ref = _this.listeners;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          results.push(listener(location));
        }
        return results;
      };
    })(this);
    this.registerListener = function(listener) {
      return this.listeners.push(listener);
    };
    this.popListener = function(idx) {
      if (idx == null) {
        idx = -1;
      }
      return this.listeners.splice(idx, 1);
    };
    this.simpleLocation = function(location) {
      var i, len, prop, propertiesToCopy, simple;
      propertiesToCopy = ['accuracy', 'bounds', 'latlng', 'timestamp'];
      simple = {};
      for (i = 0, len = propertiesToCopy.length; i < len; i++) {
        prop = propertiesToCopy[i];
        simple[prop] = location[prop];
      }
      return simple;
    };
    this.setView = function(location) {
      var zoom;
      zoom = location.accuracy != null ? Math.round(location.accuracy / 2) : 16;
      return this.map.setView(location.latlng, zoom);
    };
    this.addPin = (function(_this) {
      return function(location, popup) {
        var marker;
        marker = L.marker(location.latlng).addTo(_this.map);
        if (popup != null) {
          return marker.bindPopup(popup).openPopup();
        }
      };
    })(this);
    this.locate = function(popup, circle, options) {
      if (circle == null) {
        circle = false;
      }
      if (options == null) {
        options = {
          setView: true,
          maxZoom: 16
        };
      }
      this.registerListener((function(_this) {
        return function(location) {
          var popupText, radius;
          radius = location.accuracy / 2;
          popupText = popup != null ? popup(location) : null;
          _this.addPin(location, popupText);
          if (circle) {
            L.circle(location.latlng, radius).addTo(_this.map);
          }
          return _this.popListener();
        };
      })(this));
      return this.map.locate(options);
    };
    return null;
  }).service('ProfileService', function($localStorage) {
    this.newLocation = void 0;
    this.persist = function(profileData) {
      if (profileData == null) {
        profileData = this.profileData;
      }
      console.log('Persisting:', JSON.stringify(profileData));
      return $localStorage.setObject('profiles', profileData);
    };
    this.getProfiles = function() {
      return this.profileData.profiles;
    };
    this.getProfile = function(id) {
      return this.profileData.profiles[id];
    };
    this.putProfile = function(id, profile) {
      return this.profileData.profiles[id] = profile;
    };
    this.putProfile = function(profile) {
      return this.profileData.profiles[profile.id] = profile;
    };
    this.newProfile = function() {
      var newProfile, ref;
      this.profileData.lastId += 1;
      newProfile = {
        id: (ref = this.profileData.lastId) != null ? ref : 0
      };
      this.putProfile(newProfile);
      return newProfile;
    };
    this.profileData = $localStorage.getObject('profiles');
    if (this.profileData == null) {
      this.profileData = {
        lastId: 0,
        profiles: {}
      };
      this.persist(this.profileData);
    }
    return null;
  }).service('LocationService', function() {
    this.currentLocation = void 0;
    return null;
  }).service('RestService', function($rootScope, $ionicUser, $http, filterFilter) {
    this.endpointUrl = $rootScope.config.api.mainUrl;
    this.getApiUrl = function(target) {
      return this.endpointUrl + $rootScope.config.api.endpoints[target].url;
    };
    this.getUser = function() {
      var user;
      user = $ionicUser.get();
      if (!user.user_id) {
        user.user_id = $ionicUser.generateGUID();
      }
      return user;
    };
    this.selectiveCopy = function(obj, properties) {
      var i, len, newObj, prop;
      newObj = {};
      for (i = 0, len = properties.length; i < len; i++) {
        prop = properties[i];
        newObj[prop] = obj[prop];
      }
      return newObj;
    };
    this.findJavaClass = function(inputConfig, inputValue) {
      var ref;
      if (inputConfig.javaClass != null) {
        return inputConfig.javaClass;
      } else {
        if (inputConfig.options != null) {
          return (ref = inputConfig.options[inputValue.value]) != null ? ref.javaClass : void 0;
        }
      }
    };
    this.getValue = function(config, input) {
      var value;
      value = input.value;
      if (config.valueType != null) {
        switch (config.valueType) {
          case 'int':
            value = parseInt(value);
            break;
          case 'float':
            value = parseFloat(value);
        }
      }
      return value;
    };
    this.transformProfile = function(profile) {
      var classFrom, config, i, javaClass, len, newProfile, operand, prop, ref, value, valueFrom;
      newProfile = this.selectiveCopy(profile, ['name', 'location', 'id']);
      newProfile.rule = {
        '@class': 'JSONAnd',
        ofOperands: []
      };
      ref = profile.properties != null;
      for (i = 0, len = ref.length; i < len; i++) {
        prop = ref[i];
        config = $rootScope.config.profile.properties[prop.name];
        operand = {
          '@class': 'JSONMatchToStation',
          toStation: newProfile.location
        };
        console.log('Prop:', prop);
        console.log('Config:', config);
        switch (config.javaStructure.type) {
          case 'attributeToObject':
            classFrom = config.javaStructure.classFrom;
            valueFrom = config.javaStructure.valueFrom;
            javaClass = this.findJavaClass(config.inputs[classFrom], prop.inputs[classFrom]);
            value = this.getValue(config.inputs[valueFrom], prop.inputs[valueFrom]);
            operand.matchOperator = {
              '@class': javaClass,
              attribute: prop.name,
              toObject: value
            };
        }
        newProfile.rule.ofOperands.push(operand);
      }
      return newProfile;
    };
    this.sendProfile = function(profile) {
      var payload, url;
      console.log('Sending profile to backend:', profile);
      url = this.getApiUrl('profile');
      payload = {
        profile: this.transformProfile(profile),
        user: this.getUser()
      };
      console.log('API URL:', url);
      console.log('Payload:', payload);
      console.log('JSON Payload:', JSON.stringify(payload));
      return null;
    };
    return null;
  });

}).call(this);

//# sourceMappingURL=maps/application.js.map
