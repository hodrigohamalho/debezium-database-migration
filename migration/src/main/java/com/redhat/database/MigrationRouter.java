package com.redhat.database;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.dataformat.JsonLibrary;

public class MigrationRouter extends RouteBuilder{

    @Override
    public void configure() throws Exception {

        interceptFrom("kafka*").when(body().isNull()).stop();
         
        from("kafka:oracle-19c-orapoc.OT.KEYS?brokers=my-cluster-kafka-bootstrap.database-migration.svc:9092&groupId=migrationConsumer")
            .routeId("table-migration-consumer")
            .log("Message received from Kafka: ${body}")
            .unmarshal().json(JsonLibrary.Jackson)
            .setHeader("op", simple("${body[payload][op]}"))
            .choice()
                .when(header("op").isEqualTo("c"))
                    .log("insert operation")
                .when(header("op").isEqualTo("u"))
                    .log("update operation")
                .when(header("op").isEqualTo("d"))
                    .log("delete operation");
            
    }
    
}
