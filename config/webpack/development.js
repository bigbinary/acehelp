process.env.NODE_ENV = process.env.NODE_ENV;
process.env.HEROKU_URL =
    "https://" + process.env.HEROKU_APP_NAME + ".hrokuapp.com";

const environment = require("./environment");

module.exports = environment.toWebpackConfig();
