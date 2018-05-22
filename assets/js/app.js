// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.css'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//

import Elm from '../src/Main.elm'

let endpoint =
  (document.location.protocol === 'https:' ? 'wss://' : 'ws://') +
  document.location.host +
  '/socket/websocket'
let app = Elm.Main.fullscreen(endpoint)

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
