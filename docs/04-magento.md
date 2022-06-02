# Working with Magento

## Interacting with the CLI

### Composer

There are two make targets that can be used to interact with composer:

- `make composer`: runs composer. Example: `make composer c="require vendor/package:^1.0"`.
- `make vendor/bin`: runs a binary file located in vendor/bin. Example: `make vendor-bin c=phpcs`.

The Makefile automatically runs the command "composer install" if the vendor directory does not exist.
You don't need to run it manually.

### Magento CLI

The command "bin/magento" can be executed with `make magento`.

Example: `make magento c=indexer:status`.

**Aliases**

The Makefile also provides aliases for commands that are often used.
For example, `make cc type="config layout"` is the same as `make magento c="cache:clean config layout"`.
You can display the list of all available aliases by typing `make help`.

**Debug**

All Magento targets accept a parameter named `debug`.
This can be used to [debug a Magento command](07-xdebug.md).
Example: `make setup-upgrade debug=1`

## Backend Development

### Managing the Cache

After a cache flush, Magento takes a lot of time to rebuild the cache.
To speed up this process, after you made a change to the code, clear only the cache types that were affected by your modifications.

For example, if you made a change in a layout file, run this command: `make cc type=layout`.

### Crontab

By default, the cron container is enabled.

If it takes too much resource on your computer, you can disable it with the following command:

```
make toggle-cron
```

### Debugging MySQL Queries

You can use the [Smile Debug Toolbar module](https://github.com/Smile-SA/magento2-module-debug-toolbar) to display the SQL queries that are executed to build a page:

1. Make sure that the module is enabled in the admin area (Stores > Configuration > Smile Debug Toolbar).
2. Go to the page that you can to debug on the frontend store.
   The debug toolbar is displayed in the top right corner of the page.
3. Click on "Show MySQL queries".
   A modal dialog will display the list of all SQL queries that were executed in the context of this HTTP request.
   Clicking on a SQL query displays the related PHP trace.

It is also possible to debug XHR requests and graphql queries, because the debug toolbar displays the last 5 HTTP requests that were executed.

If the debug toolbar does not appear on the frontend, go to the Smile Debug Toolbar configuration section in the admin area, and save the config again.

### Displaying Class Information

To display information about a class, run the following command:

```
make magento c="dev:di:info <classname>"
```

For example:

```
make magento c="dev:di:info Magento\Catalog\Model\Product"
```

This command outputs the following information:

- The actual class that is instantiated (e.g. if a preference was declared).
- The constructor arguments.
- The plugins attached to this class.

## Frontend Development

### Grunt

Grunt can be executed with `make grunt`.

You can use the following commands (replace "mytheme" by your theme name, defined in dev/tools/grunt/configs/local-themes.js):

- `make grunt c=watch`
- `make grunt c="clean:mytheme"`
- `make grunt c="exec:mytheme"`
- `make grunt c="less:mytheme"`

### Template Hints

You can enable template hints by running the following commands:

```
make magento c=dev:template-hints:enable && make cc type="config block_html full_page"
```

To disable template hints:

```
make magento c=dev:template-hints:disable && make cc type="config block_html full_page"
```
