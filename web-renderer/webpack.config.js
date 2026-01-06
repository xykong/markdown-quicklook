const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/i,
        type: 'asset/inline',
      },
    ],
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
    fallback: {
        "fs": false,
        "path": false
    }
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
    clean: true,
    publicPath: '', // Ensure relative paths for fonts/assets loaded via CSS
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
    }),
    new HtmlWebpackPlugin({
      template: 'src/template.html',
      inject: 'body',
      scriptLoading: 'blocking' // Ensure scripts load before we try to use them if manually calling
    }),
    new webpack.DefinePlugin({
      'process.env.BUILD_TIME': JSON.stringify(new Date().toISOString()),
      'process.env.VERSION': JSON.stringify(require('./package.json').version),
    }),
  ],
  performance: {
    maxEntrypointSize: 4000000,
    maxAssetSize: 4000000,
  },
};
