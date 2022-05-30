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
        filename: '[name].[hash].js'
    },

    module: {
        rules: [
            {
                test: /\.hbs$/,
                exclude: /node_modules/,
                loader: 'handlebars-loader'
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack-loader?verbose=true&warn=true'
            }
        ],

        noParse: /\.elm$/,
    },

    plugins: [
        new webpack.EnvironmentPlugin(["API_TOKEN"]),
        new HtmlWebpackPlugin({
            template: 'src/static/index.html.hbs',
            minfy: false,
        }),
        new CopyWebpackPlugin({
            patterns: [ { from: 'static', to: 'static' } ],
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
