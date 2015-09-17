angular.module 'starter.directives', []

.directive 'profileInput', () ->
  restrict: 'E'
  scope:
    input: '='
    profile: '='
    property: '='
  link: (scope, element, attrs) ->
    scope.getContentUrl = () ->
      "templates/inputs/#{scope.input.type}.html"
  template: '<div ng-include="getContentUrl()"></div>'
  controllerAs: 'inputCtrl'
  controller: ($rootScope, $scope) ->
    $scope.asList = $rootScope.asList
