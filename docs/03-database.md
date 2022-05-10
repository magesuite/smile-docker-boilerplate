# Working with the Database

## Accessing the Database

You can access the database by running the following command:

```
make db
```

If Magento was properly installed, the command `show tables` will then list all the tables of the database.

## Importing the Database

You can import a dump file by running the following command:

```
make db-import filename=/path/to/dump.sql
```

Where "/path/to/dump.sql" is the location of your dump file on your filesystem.

## Exporting the Database

You can create a database dump by running the following command:

```
make db-export filename=dump.sql
```

This will create a file named "dump.sql" at the root of your project.
