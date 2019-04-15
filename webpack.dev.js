const assert = require('assert');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

const config = merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',
});

const elmLoaderConfigs = config.module.rules.filter((rule) => rule.loader.startsWith('elm-webpack-loader'));
assert.equal(elmLoaderConfigs.length, 1);
elmLoaderConfigs[0].options = {
    debug: true,
};

module.exports = config;
