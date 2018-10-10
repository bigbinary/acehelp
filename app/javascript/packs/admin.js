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
import "csrf-xhr";
import "../../assets/stylesheets/admin/index.scss";
import AttachmentUploader from "./attachment_uploader";

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

    // On clicking the attachment button in the trix editor's toolbar,
    // we will the file browser to allow user to choose files.
    // Once files are selected, we will insert them into editor,
    // making the editor to invoke an "trix-attachment-add" event
    // for the each file separately.
    app.ports.addAttachments.subscribe(() => {
        const editorNode = document.querySelector("trix-editor");
        const fileInput = document.createElement("input");

        fileInput.setAttribute("type", "file");
        fileInput.setAttribute("multiple", "");

        fileInput.addEventListener("change", function(event) {
            const files = Array.from(this.files);

            return files.map(file => editorNode.editor.insertFile(file));
        });

        fileInput.click();
    });

    // OUTGOING PORTS
    document.addEventListener("trix-initialize", function(event) {
        app.ports.trixInitialize.send(null);
    });

    document.addEventListener("trix-attachment-add", event => {
        const attachment = event.attachment;
        const editorParentNode = event.target.parentNode;
        const apiKey = editorParentNode.getAttribute("data-api-key");
        const attachmentsPath = editorParentNode.getAttribute(
            "data-attachments-path"
        );

        if (apiKey && attachment.file && attachmentsPath) {
            const uploader = new AttachmentUploader(
                apiKey,
                attachment,
                attachmentsPath
            );

            return uploader.upload();
        }
    });
});
