import Elm from "../Client/Main";
import "../../assets/stylesheets/client/index.scss";

/**
 * The AceHelp namespace provides APIs that allow users to configure and control the AceHelp widget
 */
var AceHelp = (function () {
    var internal = {};

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

    internal.insertWidget = insertWidget;

    return {
        /**
         * _internal is a sub-namespace that holds methods that are to be used internally
         * @ignore
         */
        _internal: internal,

        /**
         * Provide user information such as name and email to the widget
         *
         * @param {Object} user An object with the user name and email strings
         *
         * @example
         *
         * window.AceHelp.userInfo({ name: "John Doe", email: "john@doe.com"})
         */
        userInfo: function ({ name, email }) {
            if (typeof name === "string" && typeof email === "string") {
                Elm.ports.userInfo.send({ name, email });
            } else {
                throw new Error(
                    "AceHelp: Name and email are required to be of string type"
                );
            }
        }
    };
})();

window.AceHelp = AceHelp;
