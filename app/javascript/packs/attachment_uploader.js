export default class AttachmentUploader {
    constructor(apiKey, attachment, uploadPath) {
        this.apiKey = apiKey;
        this.attachment = attachment;
        this.uploadPath = uploadPath;

        this.request = this.initializeRequest();
    }

    upload() {
        return this.request.send(this.formData());
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
        const { attachment_url } = JSON.parse(responseText);

        return this.attachment.setAttributes({
            url: attachment_url,
            href: attachment_url
        });
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

        return this.attachment.remove();
    }
}
