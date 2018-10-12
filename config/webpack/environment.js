const { environment } = require("@rails/webpacker");
const erb = require("./loaders/erb");
const elm = require("./loaders/elm");

environment.loaders.append("elm", elm);
environment.loaders.append("erb", erb);
module.exports = environment;
