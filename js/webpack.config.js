module.exports = {
  context: __dirname,
  entry: "./sale.js",
  output: {
    path: "./",
    filename: "bundle.js"
  },
  resolve: {
    extensions: [".js"]
  },
  module: {
    loaders: [
      {
        test: /\.node$/,
        loader: "node-loader"
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader"
      },
    ]
  },
  devtool: 'source-maps'
};
