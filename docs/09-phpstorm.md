# PhpStorm Configuration

## Magento Plugin

A Magento plugin is available in PhpStorm.

You can install it by following these steps:

1. Open the PhpStorm configuration (File > Settings in the menu).
2. In the **Plugins** section, click on "Marketplace", then type "Magento" in the search box.
3. Install the plugin named "Magento PhpStorm".
4. Restart PhpStorm.

You can then enable the plugin on a per-project basis:

1. Open the settings again, and go to PHP > Frameworks.
2. In the Magento section:
   - Check "Enable Magento integration".
   - Specify the Magento installation path.
   - Click on "Regenerate URN mappings".
3. Wait for the project to be reindexed.

## Code Inspection

Code inspection in PhpStorm doesn't work out of the box with docker.
The recommended way to validate your code is to [use the Makefile](06-code-quality.md).

However, if you still want to enable the code inspection in PhpStorm, follow these steps:

1. Open the PhpStorm configuration (File > Settings in the menu).

2. In the **PHP** section, add a CLI interpreter (choose the template "From Docker"):

    - Select "Docker Compose"
    - Configuration files: select the files "compose.yaml" and "compose.override.yaml" (in this order)
    - Service: select "php"

   Optional: to maximize performance, select "Connect to an existing container" in the Lifecycle section of the interpreter.

3. In the same **PHP** section, set the path mapping:

    - Local path: select the magento directory
    - Remote path: `/var/www/html`

4. Go to **PHP > Quality Tools**. For each tool, select the php interpreter that you created.

5. Go to **Editor > Inspections**. In the subsection **PHP > Quality tools**, enable and configure the following tools (disable the others):

    - PHP_CodeSniffer validation:
        - Uncheck "Installed standard path"
        - Set "Coding standard" to "custom", and use the value `phpcs.xml.dist`
    - PHP Mess Detector validation: nothing to do (except enabling it)
    - PHPStan validation:
        - Set "Configuration file" to `phpstan.neon.dist`
