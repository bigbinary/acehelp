"use strict";

const STATIC_IMAGE_MAX_SIZE_IN_BYTES = 5 * 1024 * 1024; // 5 MB
const ANIMATED_IMAGE_MAX_SIZE_IN_BYTES = 10 * 1024 * 1024; // 10 MB
const ALLOWED_ATTACHMENT_MIME_TYPES = ["image/jpeg", "image/png", "image/gif"];

Object.freeze(ALLOWED_ATTACHMENT_MIME_TYPES);

export default class AttachmentUploader {
    constructor(apiKey, attachment, uploadPath, finishCallback) {
        this.apiKey = apiKey;
        this.attachment = attachment;
        this.uploadPath = uploadPath;
        this.validationError = null;
        this.finishCallback = finishCallback;

        this.request = this.initializeRequest();
    }

    upload() {
        this.validateAttachment();

        if (this.validationError) {
            this.removeAttachment();

            alert(this.validationError);

            return false;
        } else {
            return this.request.send(this.formData());
        }
    }

    validateAttachment() {
        const { file } = this.attachment;
        const { type, size } = file;
        const bytesToMBs = bytes =>
            parseFloat(bytes / (1024 * 1024)).toFixed(2);

        if (!ALLOWED_ATTACHMENT_MIME_TYPES.includes(type)) {
            this.validationError =
                "Sorry, the submitted file cannot be uploaded. Please select a JPG, JPEG, PNG or GIF file instead and try again.";

            return;
        }

        if (size == 0) {
            this.validationError =
                "The submitted file was empty or corrupt. Please select a valid file.";

            return;
        }

        if (type !== "image/gif" && size > STATIC_IMAGE_MAX_SIZE_IN_BYTES) {
            const allowedSizeInMBs = bytesToMBs(STATIC_IMAGE_MAX_SIZE_IN_BYTES);

            this.validationError = `Sorry, the size of the submitted image file was bigger than ${allowedSizeInMBs} MB. Please select a smaller file and try again.`;

            return;
        }

        if (type === "image/gif" && size > ANIMATED_IMAGE_MAX_SIZE_IN_BYTES) {
            const allowedSizeInMBs = bytesToMBs(
                ANIMATED_IMAGE_MAX_SIZE_IN_BYTES
            );

            this.validationError = `Sorry, the size of the submitted GIF file was bigger than ${allowedSizeInMBs} MB. Please select a smaller file and try again.`;

            return;
        }
    }

    initializeRequest() {
        const request = new XMLHttpRequest();

        request.open("POST", this.uploadPath, true);

        request.setRequestHeader("api-key", this.apiKey);

        request.upload.onprogress = this.uploadProgressHandler.bind(this);
        request.onload = this.uploadFinishHandler.bind(this);

        return request;
    }

    formData() {
        const formData = new FormData();
        const { file } = this.attachment;
        const { name, type } = file;

        formData.append("attachment[filename]", name);
        formData.append("attachment[content_type]", type);
        formData.append("attachment[file]", file);

        return formData;
    }

    uploadProgressHandler(event) {
        const progress = (event.loaded / event.total) * 100;

        return this.attachment.setUploadProgress(progress);
    }

    uploadFinishHandler() {
        const { status } = this.request;

        return status === 201
            ? this.uploadSuccessHandler()
            : this.uploadErrorHandler();
    }

    uploadSuccessHandler() {
        const { responseText } = this.request;
        const { attachment_url, attachment_id } = JSON.parse(responseText);

        const result = this.attachment.setAttributes({
            url: attachment_url,
            href: attachment_url,
            id: attachment_id
        });

        this.executeFinishCallback();

        return result;
    }

    uploadErrorHandler() {
        const { responseText, status } = this.request;
        let errorMessage = "";

        try {
            errorMessage = JSON.parse(responseText).error;
        } catch (e) {}

        alert(
            `Sorry, an error occurred while uploading the file. ${errorMessage} [Status: ${status}]`
        );

        return this.removeAttachment();
    }

    removeAttachment() {
        const result = this.attachment.remove();

        this.executeFinishCallback();

        return result;
    }

    executeFinishCallback() {
        if (this.finishCallback && typeof this.finishCallback === "function") {
            this.finishCallback(this.attachment);
        }
    }
}
