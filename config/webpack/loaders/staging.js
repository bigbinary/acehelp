process.env.NODE_ENV = process.env.NODE_ENV || "staging";
process.env.HEROKU_URL =
    "https://" + process.env.HEROKU_APP_NAME + "herokuapp.com" ||
    "https://staging.acehelp.com";

const environment = require("./environment");

module.exports = environment.toWebpackConfig();
