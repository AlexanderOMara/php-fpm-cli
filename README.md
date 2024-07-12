# php-fpm-cli

Run PHP scripts through FastCGI from the command line

# Overview

A PHP CLI script to run PHP scripts through a php-fpm worker that is also a pure-PHP FastCGI request CLI.

# Usage

```
Usage: php-fpm-cli -c <socket> [options] [script]

  -c, --connect <socket>     Connect to <socket> file or host:port
  -p, --param <key>=<value>  FCGI request <key>=<value> param
  -b, --body <body>          FCGI request STDIN <body>
  -d, --data <file>          FCGI request STDIN body from <file>
  -i, --include              FCGI response headers included in output
  -t, --timeout <duration>   Connect timeout in milliseconds
  -h, --help                 Display help and exit
  -v, --version              Display version and exit
```

# Examples

## Clear opcache

The cache used by fpm workers and the CLI is separate, so we need to run it inside a php-fpm worker.

```php
<?php
printf("%d\n", opcache_reset());
```

```console
$ php-fpm-cli -c /var/run/php-fpm.sock opcache-reset.php
1
```

## GET request with a query string

A query string can be pass by the FCGI parameter.

```php
<?php
var_dump($_GET);
```

```console
$ php-fpm-cli -c /var/run/php-fpm.sock -p 'QUERY_STRING=foo=bar&baz=qux' dump-get.php
array(2) {
  ["foo"]=>
  string(3) "bar"
  ["baz"]=>
  string(3) "qux"
}
```

## POST request

A request body can be added which PHP will automatically parse with the correct content type.

```php
<?php
var_dump($_POST);
```

```console
$ php-fpm-cli -c /var/run/php-fpm.sock -p 'CONTENT_TYPE=application/x-www-form-urlencoded' -b 'foo=bar&baz=qux' dump-post.php
array(2) {
  ["foo"]=>
  string(3) "bar"
  ["baz"]=>
  string(3) "qux"
}
```

## PUT request

The default `REQUEST_METHOD` can be overridden.

```php
<?php
echo md5(file_get_contents('php://input')), "\n";
```

```
Hello world!
```

```console
$ php-fpm-cli -c /var/run/php-fpm.sock -p 'REQUEST_METHOD=PUT' -d file.txt put.php
86fb269d190d2c85f6e0468ceca42a20
```

## Headers

Sending and printing headers (a non-2XX response produces a non-zero exit code).

```php
<?php
http_response_code(403);
header("X-Foo: {$_SERVER['HTTP_X_BAZ']}");
echo "Headers above\n";
```

```console
$ php-fpm-cli --c /var/run/php-fpm.sock -p 'HTTP_X_BAZ=Bar' -i headers.php
Status: 403 Forbidden
X-Powered-By: PHP/X.X.X
X-Foo: Bar
Content-type: text/html; charset=UTF-8

Headers above
$ echo $?
1
```

## Manual request

The FastCGI request can be manually constructed with just params.

```php
<?php
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']}\n";
```

```console
$ php-fpm-cli -c /var/run/php-fpm.sock -p 'SCRIPT_FILENAME=/path/to/script.php' -p 'REQUEST_METHOD=GET'
GET /path/to/script.php
```

# License

Copyright (c) 2024 Alexander O'Mara

Licensed under the Mozilla Public License, v. 2.0.

If this license does not work for you, feel free to contact me.
