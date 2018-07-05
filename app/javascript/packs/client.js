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
        document.body.appendChild(node);
    }

    function _userInfo({ name, email }) {
        if (!_app) throw new Error("AceHelp: Widget has not been initialized");
        if (typeof name !== "string" && typeof email !== "string") {
            throw new Error(
                "AceHelp:userInfo: name and email are required to be of string type"
            );
        }
        _app.ports.userInfo.send({ name, email });
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
         *
         * window.AceHelp.userInfo({ name: "John Doe", email: "john@doe.com"})
         */
        userInfo: _userInfo
    };
})();

window.AceHelp = AceHelp;
