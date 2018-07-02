/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Elm from "../Client/Main";
import "../../assets/stylesheets/client/index.scss";

window._ace = (function() {
  function insertWidget({ apiKey }) {
    var domId = "acehelp-hook";
    var node = document.getElementById("acehelp-hook");
    node = node || document.createElement("div");
    node.id = domId;
    Elm.Main.embed(node, {
      node_env: process.env.NODE_ENV,
      api_key: apiKey
    });
    document.body.appendChild(node);
  }

  return {
    insertWidget: insertWidget
  };
})();
