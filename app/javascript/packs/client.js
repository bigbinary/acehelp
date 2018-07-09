import Elm from "../Client/Main";
import "../../assets/stylesheets/client/index.scss";

/**
 * The AceHelp namespace provides APIs that allow users to configure and control the AceHelp widget
 */
var AceHelp = (function() {
    var internal = {};
    var _app;

    function _insertWidget({ apiKey }) {
        var domId = "acehelp-hook";
        var node = document.getElementById("acehelp-hook");
        node = node || document.createElement("div");
        node.id = domId;
        _app = Elm.Main.embed(node, {
            node_env: process.env.NODE_ENV,
            api_key: apiKey
        });
        _bindDataElements();
        document.body.appendChild(node);
    }

    function _userInfo(user) {
        if (!_app) throw new Error("AceHelp: Widget has not been initialized");
        if (!user) throw new Error("AceHelp:userInfo: expecting one parameter");
        if (user.name && typeof user.name !== "string")
            throw new Error(
                "AceHelp:userInfo: name is required to be of string type"
            );
        if (user.email && typeof user.email !== "string")
            throw new Error(
                "AceHelp:userInfo: email is required to be of string type"
            );

        _app.ports.userInfo.send(user);
    }

    function _onDataElementClick(e) {
        var articleId = e.target.getAttribute("data-acehelp-article");
        _app.ports.openArticle(articleId);
    }

    function _bindDataElements() {
        var aceDataElements = document.querySelectorAll(
            "[data-acehelp-article]"
        );
        aceDataElements.forEach(function(elem) {
            elem.onclick = _onDataElementClick;
        });
    }

    internal.insertWidget = _insertWidget;

    return {
        /**
         * _internal is a sub-namespace that holds methods that are to be used internally
         * @ignore
         */
        _internal: internal,

        /**
         * Provide user information such as name and email to the widget. This will auto fill certain forms
         *
         * @param {Object} user An object with the user name and email strings
         *
         * @example
         * window.AceHelp.userInfo({ name: "John Doe", email: "john@doe.com"})
         */
        userInfo: _userInfo
    };
})();

window.AceHelp = AceHelp;
