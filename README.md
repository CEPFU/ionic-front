# CoffeeScript Ionic Starter

Starting point for developing Ionic apps with coffeescript.



## Getting Started

### Initial setup:
Install the Cordova plugins by running:

```sh
ionic state restore
```

### Running
Execute
```sh
./run.sh
```

to start the app in a browser.

Coffeescript files in www/coffee will be compiled to JS and concated into www/js/application.js.  Sass files in www/sass will be compiled to CSS and concated into www/css/style.css.

Changes to any files in the project directory will trigger a reload in your browser, complete with your newly concated+compiled sass+coffee files!

## Troubleshooting

If you get an error on running `gulp watch`, try `npm install -g gulp-cli`.
