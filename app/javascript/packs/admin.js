/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import { Elm } from "../Admin/Main";
import "bootstrap";
import "trix";
import "../../assets/stylesheets/admin/index.scss";

document.addEventListener("DOMContentLoaded", () => {
    var node = document.getElementById("admin-hook");
    var org_key_target = document.querySelector("meta[name=organization_key]");
    var org_name_target = document.querySelector(
        "meta[name=organization_name]"
    );
    var user_id_target = document.querySelector("meta[name=user_id]");
    var user_email_target = document.querySelector("meta[name=user_email]");
    var app_url_target = document.querySelector("meta[name=app_url]");
    var org_name = org_name_target.getAttribute("value");
    var org_key = org_key_target.getAttribute("value");
    var user_id = user_id_target.getAttribute("value");
    var user_email = user_email_target.getAttribute("value");
    var app_url = app_url_target.getAttribute("value");
    var app = Elm.Main.init({
        node: node,
        flags: {
            node_env: process.env.NODE_ENV,
            organization_key: org_key,
            organization_name: org_name,
            user_id: user_id,
            user_email: user_email,
            app_url: app_url
        }
    });

    // INCOMING PORTS
    app.ports.insertArticleContent.subscribe(function(html) {
        var trixEl = document.querySelector("trix-editor");
        if (trixEl) {
            trixEl.editor.loadHTML(html);
        }

        var divEl = document.getElementById("trix-show");
        if (divEl) {
            divEl.innerHTML = html;
        }
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

    app.ports.setEditorHeight.subscribe(({ editorId, height }) => {
        const editorNode = document.getElementById(editorId);

        if (editorNode) {
            const heightInPx = (height || editorNode.style.minHeight) + "px";

            editorNode.style.minHeight = heightInPx;
            editorNode.style.maxHeight = heightInPx;
        }
    });

    // OUTGOING PORTS
    document.addEventListener("trix-initialize", function(event) {
        app.ports.trixInitialize.send(null);
    });

    const uploadEndpoint = "/upload";

    function uploadAttachment(attachment) {
        const file = attachment.file;
        const form = new FormData();
        const xhr = new XMLHttpRequest();

        form.append("attachment[filename]", file.name);
        form.append("attachment[content_type]", file.type);
        form.append("attachment[file]", file);

        xhr.open("POST", uploadEndpoint, true);

        xhr.upload.onprogress = event => {
            const progress = (event.loaded / event.total) * 100;

            return attachment.setUploadProgress(progress);
        };

        xhr.onload = () => {
            if (xhr.status === 201) {
                const response = JSON.parse(xhr.responseText);
                const attachmentURL = response.attachment_url;

                return attachment.setAttributes({
                    url: attachmentURL,
                    href: attachmentURL
                });
            }
        };

        return xhr.send(form);
    }

    document.addEventListener("trix-attachment-add", event => {
        const attachment = event.attachment;
        if (attachment.file) {
            return uploadAttachment(attachment);
        }
    });

    document.addEventListener("trix-change", function(event) {
        app.ports.trixChange.send(event.target.innerHTML);
    });
});
