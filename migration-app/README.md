# PostgreSQL Kafka Sink

This project uses Camel Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

Run a local Kafka using `docker-compose`

```shell script
docker-compose up
```

If you prefer to not have Postgres and Oracle instance in your environment, you can do a port-forward to Openshift:

```shell script
oc port-forward postgresql-1-l8bmp 5432:5432
```

You can run your application in dev mode that enables live coding using:
```shell script
./mvnw compile quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at http://localhost:8080/q/dev/.

## Packaging and running the application

The application can be packaged using:
```shell script
./mvnw package
```
It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:
```shell script
./mvnw package -Dquarkus.package.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using: 
```shell script
./mvnw package -Pnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using: 
```shell script
./mvnw package -Pnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/migration-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult https://quarkus.io/guides/maven-tooling.


## Useful commands

Port-forward PostgreSQL port to use it locally

```shell script
oc port-forward postgresql-1-l8bmp 5432:5432
```

Connect to migration-app_kafka_1

```shell script
./kafka-topics.sh --bootstrap-server localhost:9092 --topic oracle-19c-orapoc.OT.KEYS --create --partitions 3 --replication-factor 1
```

Insert event in Kafka (Mock Debezium generation event)

```shell script
kcat -b 0.0.0.0:9092 -t oracle-19c-orapoc.OT.KEYS -P debezium-event-examples/insert-content.json
```