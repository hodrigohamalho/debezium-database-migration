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