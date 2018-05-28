/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Elm from "../Main";
import "../../assets/stylesheets/application.css";
import "../../assets/stylesheets/reset.scss";

document.addEventListener("DOMContentLoaded", () => {
  var domId = "acehelp-hook";
  var node = document.getElementById("acehelp-hook");
  node = node || document.createElement("div");
  node.id = domId;
  Elm.Main.embed(node);
  document.body.appendChild(node);
});
