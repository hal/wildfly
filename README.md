# WildFly Development Images

This repository contains scripts to run WildFly standalone images for all major WildFly version >= 10.0.0.Final. The images build on top of [quay.io/wildfly/wildfly](https://quay.io/repository/wildfly/wildfly) and are hosted at [quay.io/halconsole/wildfly](https://quay.io/repository/halconsole/wildfly). 

The images are specifically intended for development of WildFly and its components and subsystems. If you're looking for (Jakarta EE) application development with WildFly, the official [WildFly images](https://quay.io/organization/wildfly) might be a better match. 

The images add an admin user `admin:admin`, expose the management interface at port `9990` and add [allowed origins](https://docs.wildfly.org/26/wildscribe/core-service/management/management-interface/http-interface/index.html#attr-allowed-origins) for

- http://localhost:8888
- http://hal.github.io
- https://hal.github.io

The allowed origins are meant to run [HAL](https://hal.github.io) in [standalone mode](https://hal.github.io/documentation/get-started/#standalone-mode) and connect to the running WildFly instances.

## Scripts

Most scripts require the major WildFly version as a two digit number: `nn` >= 10. All scripts support the following flags:

```shell
-h, --help      Prints help information
-v, --version   Prints version information
--no-color      Uses plain text output
```

### `start-wildfly.sh <nn> [<parameters>]`

Starts a WildFly standalone server for the specified version. The management port `9990` is published as `99<nn>`. Parameters are passed to the `standalone.sh` script of WildFly. 

Example:

```shell
start-wildfly.sh 26 -c standalone-microprofile.xml
```

### `cli-wildfly.sh <nn> [<parameters>]`

Connects to the CLI of the specified WildFly version. Parameters are passed to main class of `wildfly-cli-client.jar`. 

Example:

```shell
cli-wildfly.sh 26 --file=commands.txt
```

### `hal-wildfly.sh <nn>`

Opens HAL in the default browser for the specified WildFly version.

### Remaining scripts

`build-wildfly.sh`, `push-wildfly.sh` and `bulk-*.sh` are used to build and push WildFly images. 
