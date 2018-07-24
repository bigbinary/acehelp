/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Elm from "../Admin/Main";
import "bootstrap";
import "trix";
import "../../assets/stylesheets/admin/index.scss";

document.addEventListener("DOMContentLoaded", () => {
    var node = document.getElementById("admin-hook");
    var target = document.querySelector("meta[name=organization_key]");
    var org_key = target.getAttribute("value");
    Elm.Main.embed(node, {
        node_env: process.env.NODE_ENV,
        organization_key: org_key
    });
});

//TODO: Handle file uploads
document.addEventListener("trix-attachment-add", function(event) {
    var attachment;
    attachment = event.attachment;
    if (attachment.file) {
        //return uploadAttachment(attachment);
        //console.log(attachment.file);
    }
});
