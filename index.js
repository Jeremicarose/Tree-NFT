const path = require('path');
const webpack = require('webpack');
const WebpackDevServer = require('webpack-dev-server');
const webpackConfig = require('./webpack.config');

const webpackDevServerOptions = {
  contentBase: path.join(process.cwd(), 'docs'),
  publicPath: '/',
  historyApiFallback: true,
  hot: true,
  host: '0.0.0.0',
};

const compiler = webpack(webpackConfig);
const devServer = new WebpackDevServer(compiler, webpackDevServerOptions);

const port = process.env.PORT || 3000;
devServer.listen(port, '0.0.0.0', (err) => {
  if (err) {
    console.error(err);
  } else {
    console.log(`App listening on http://localhost:${port}`);
  }
});
