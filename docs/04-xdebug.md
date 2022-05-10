# How to Use Xdebug

## Debugging HTTP requests

First, make sure that your browser is properly configured:

- Install a xdebug helper extension in your browser ([Firefox](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox/), [Chrome](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en)) and enabled it (xdebug icon in the address bar).
- Click on "Disable cache" in the "network" section of the dev toolbar (F12).

Then, in PhpStorm:

1. Click on "Start Listening for PHP Debug Connections" (top right corner).
2. Add a breakpoint somewhere in your code.
3. Refresh the page. It should automatically detect the Xdebug connection.

## Debugging CLI commands

There is a make target to launch PHP commands with Xdebug enabled.
Example:

```
make xdebug c=bin/magento
```

## Toubleshooting

If PhpStorm reports an issue with invalid path mapping:

1. Go to Settings > PHP > Servers.
2. Make sure that there is a server defined, and that its name is `_`.
4. Make sure that there is a path mapping between the Magento root directory and /var/www/html.
