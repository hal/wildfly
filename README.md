[![Docker Repository on Quay](https://quay.io/repository/halconsole/wildfly/status "Docker Repository on Quay")](https://quay.io/repository/halconsole/wildfly)

# WildFly Images

This repository contains scripts to run WildFly [standalone images](https://quay.io/repository/halconsole/wildfly) for all major WildFly version >= 10.0.0.Final. The images are specifically intended for development of WildFly and its components and subsystems. If yopu're looking for Jakarta EE application development with WildFly, the official [WildFly images](https://quay.io/organization/wildfly) might be a better match. 

The images add an admin user `admin:admin`, expose the management interface at port `9990` and add [allowed origins](https://docs.wildfly.org/26/wildscribe/core-service/management/management-interface/http-interface/index.html#attr-allowed-origins) for

- http://localhost:8888
- http://hal.github.io
- https://hal.github.io

The allowed origins are meant to run [HAL](https://hal.github.io) in [standalone mode](https://hal.github.io/documentation/get-started/#standalone-mode) and connect to the running WildFly instances.

## Scripts

`start-wildfly <nn>` Starts a WildFly standalone server for the specified major version. The management port `9990` is published as `99<nn>`. You can safely run multiple different versions at the same time without port conflicts.

`cli-wildfly.sh <nn>` Connects to the CLI of the specified major WildFly version.

`hal-wildfly.sh <nn>` Opens HAL in the default browser for the specified major WildFly version.

`build-wildfly`, `push-wildfly.sh`, `bulk-*.sh` Scripts to build and push WildFly images. 
