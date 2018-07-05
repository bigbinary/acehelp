var req = new XMLHttpRequest();
var script = document.createElement("script");
var link = document.createElement("link");
var baseUrl = "";
var apiKey = "YOURAPIKEY";

script.type = "text/javascript";
script.async = true;
script.onload = function () {
    var _ace = window.AceHelp;
    if (_ace) {
        _ace._internal.insertWidget({ apiKey: apiKey });
    }
};

link.rel = "stylesheet";
link.type = "text/css";
link.media = "all";

req.responseType = "json";
req.open("GET", baseUrl + "/packs/manifest.json", true);
req.onload = function () {
    var t = document.getElementsByTagName("script")[0];
    var manifest = req.response;
    link.href = baseUrl + manifest["client.css"];
    script.src = baseUrl + manifest["client.js"];
    t.parentNode.insertBefore(link, t);
    t.parentNode.insertBefore(script, t);
};
req.send();
