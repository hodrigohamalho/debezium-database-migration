# crete openshift project 
oc new-project database-migration

# install kafka cluster 
oc create -f kafka/kafka.yaml

sleep 60

# install prometheus 
oc create -f kafka/monitoring/prometheus-install

# install grafana
oc create -f kafka/monitoring/grafana-install

# install kafka connect 
#oc create -f kafka/monitoring/kafka-connect-metrics.yaml

# install mirror maker 2
# oc create -f kafka/monitoring/kafka-mirror-maker-2-metrics.yaml

oc policy add-role-to-user admin system:serviceaccount:database-migration:prometheus-server

#install Oracle (it takes forever, good luck (Y)
# oc create ...

# Install Postgres
oc new-app -f database/postgres/postgresql-persistent-template.json --param=POSTGRESQL_USER=dbuser --param=POSTGRESQL_PASSWORD=password --param=POSTGRESQL_DATABASE=sampledb --param=POSTGRESQL_VERSION=latest


# Create Oracle Database resources
./orapoc-setup.sh

# Debezium 
oc create -f kafka/debezium/debezium-secret.yaml
oc create -f kafka/debezium/debezium-role.yaml
oc create -f kafka/debezium/debezium-role-binding.yaml
oc create -f kafka/debezium/kafka-connect.yaml
oc create -f kafka/debezium/debezium-kafka-connector.yaml

