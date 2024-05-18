// Base
const dotenv = require('dotenv');
const path = require("path");
const webpack = require('webpack')

// Plugins
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');

// Load .env file
dotenv.config();

// Webpack config
module.exports = {
    entry: {
        app: ['./src/static/index.js']
    },

    output: {
        path: path.resolve(__dirname + '/dist'),
        filename: '[name].[contenthash].js'
    },

    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                },
            }
        ],

        noParse: /\.elm$/,
    },

    plugins: [
        new webpack.EnvironmentPlugin(["API_TOKEN"]),
        new HtmlWebpackPlugin({
            template: 'src/static/index.html',
            minfy: false,
        }),
        new CopyWebpackPlugin({
            patterns: [ { from: 'static', to: 'static' }, { from: '.well-known', to: '.well-known' } ],
        }),
    ],

    target: 'web',

    devServer: {
        devMiddleware: {
            stats: {
                colors: true,
                hash: false,
                modules: false,
            },
        },
    },

};
