'use strict';

require('./index.html');
require('./src/Stylesheets');

var Elm = require('./src/Main');
Elm.Main.embed(document.getElementById('main'));
