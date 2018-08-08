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
    var org_key_target = document.querySelector("meta[name=organization_key]");
    var user_id_target = document.querySelector("meta[name=user_id]");
    var user_email_target = document.querySelector("meta[name=user_email]");
    var org_key = org_key_target.getAttribute("value");
    var user_id = user_id_target.getAttribute("value");
    var heroku_url = process.env.HEROKU_URL;
    console.log(heroku_url);
    var user_email = user_email_target.getAttribute("value");
    var app = Elm.Main.embed(node, {
        node_env: process.env.NODE_ENV,
        heroku_url: process.env.HEROKU_URL,
        organization_key: org_key,
        user_id: user_id,
        user_email: user_email
    });

    // INCOMING PORTS
    app.ports.insertArticleContent.subscribe(function(html) {
        var trixEl = document.querySelector("trix-editor");
        if (trixEl) trixEl.editor.insertHTML(html);
    });

    app.ports.setTimeout.subscribe(function(time) {
        var timeoutId = setTimeout(function() {
            app.ports.timedOut.send(timeoutId);
        }, time);
        app.ports.timeoutInitialized.send(timeoutId);
    });

    app.ports.clearTimeout.subscribe(function(timeoutId) {
        clearTimeout(timeoutId);
    });

    // OUTGOING PORTS
    document.addEventListener("trix-initialize", function(event) {
        app.ports.trixInitialize.send(null);
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

    document.addEventListener("trix-change", function(event) {
        app.ports.trixChange.send(event.target.innerHTML);
    });
});
