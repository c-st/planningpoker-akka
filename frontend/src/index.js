require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./styles.css');
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');
var app = Elm.Main.embed(mountNode);