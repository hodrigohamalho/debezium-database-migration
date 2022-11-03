package com.redhat.database;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.dataformat.JsonLibrary;

public class MigrationRouter extends RouteBuilder{

    @Override
    public void configure() throws Exception {

        interceptFrom("kafka*").when(body().isNull()).stop();
         
        from("kafka:{{kafka.topic}}")
            .routeId("table-migration-consumer")
            .log("Message received from Kafka")
            .unmarshal().json(JsonLibrary.Jackson)
            .setHeader("op", simple("${body[payload][op]}"))
            .transform(simple("${body[payload][after]}"))
            .choice()
                .when(header("op").isEqualTo("c"))
                    .log("insert operation")
                    .to("direct:insert")
                .when(header("op").isEqualTo("u"))
                    .log("update operation")
                    .to("direct:update")
                .when(header("op").isEqualTo("d"))
                    .log("delete operation")
                    .to("direct:delete");
        
        from("direct:insert")
            .log("direct insert ${body[KEY]}, ${body[VALUE]}")
            .to("sql:classpath:sql/insert.sql");

        from("direct:update")
            .log("direct update");

        from("direct:delete")
            .log("delete resource");

    }
    
}
