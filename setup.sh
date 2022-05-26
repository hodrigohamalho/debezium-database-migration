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
oc create -f kafka/monitoring/kafka-connect-metrics.yaml

# install mirror maker 2
# oc create -f kafka/monitoring/kafka-mirror-maker-2-metrics.yaml

oc policy add-role-to-user admin system:serviceaccount:database-migration:prometheus-server


# oracle service account 
oc create sa oracle

oc adm policy add-scc-to-user anyuid -z oracle

oc create -f oracle-database/oracle-db-secret.yml

oc create -f oracle-database/database-deployment.yaml

oc delete limitranges database-migration-core-resource-limits