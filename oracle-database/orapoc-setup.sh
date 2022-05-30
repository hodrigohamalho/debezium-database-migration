#!/bin/bash
# This script assumes the oc tool is installed and that the working project
# is the project where the database will be deployed

# If the path to the resources is not specified, infer it from the script's location
if [ -z "$ORAPOC_SETUP_RESOURCES"]; then
    ORAPOC_SETUP_RESOURCES=$( dirname $(readlink -f $0))
fi;

# RHPDS's labs add a limitrange to all new projects. Removing them will make it easier
# for the database to start.
# It usually uses a little more than 2G of RAM and arount 200mCPU to start
oc delete limitranges --all

# Service account: An SA with the AnyUID or Privileged SCC is needed
# because the Oracle image needs to run as the 'oracle' user (UID 54321)
# ------------------------------------------------
oc create sa oracle

oc adm policy add-scc-to-user anyuid -z oracle
# ------------------------------------------------

# Secret to hold the SYS user password.
oc create -f $ORAPOC_SETUP_RESOURCES/orapoc-sys-password.yaml

# PVC for the oradata directory. This is the directory where all
# database files will be stored.
oc create -f $ORAPOC_SETUP_RESOURCES/orapoc-oradata-pvc.yaml

# Deployment for the database.
oc create -f $ORAPOC_SETUP_RESOURCES/orapoc-deployment.yaml


# Running the setup scripts for Debezium

ORACLE_DB_POD=$(oc get pod -lapp=oracle-19c-orapoc -ogo-template="{{(index .items 0).metadata.name}}")

# Create user 'OT' with password 'Orcl1234' on the PDB Oracle container and grant CONNECT and RESOURCE rpivileges
oc exec -i $ORACLE_DB_POD -- bash -c 'sqlplus sys/$ORACLE_PWD@$ORACLE_PDB as SYSDBA' <\
  $ORAPOC_SETUP_RESOURCES/database-scripts/create-ot-user.sql

# As user 'OT', create a test table on the PDB Oracle container and insert test data on it
oc exec -i $ORACLE_DB_POD -- bash -c 'sqlplus ot/Orcl1234@$ORACLE_PDB' <\
  $ORAPOC_SETUP_RESOURCES/database-scripts/create-ot-tables.sql

# Set up the archivelog functionality on the CDB Oracle container
oc exec -i $ORACLE_DB_POD -- bash -c 'sqlplus sys/$ORACLE_PWD as SYSDBA;' <\
  $ORAPOC_SETUP_RESOURCES/database-scripts/setup-archivelog.sql



# --------------------------------------------------- NEED TO CHECK EXACTLY WHAT WE SHOULD BE DOING HERE ----------------------------------------------------
# Set up tablespaces for logminer, set supplemental log configuration for the test table, create de c##dbzuser,
# and add the approrpiate privileges to the c##dbzuser user

#oc exec -i $ORACLE_DB_POD -- bash -c 'sqlplus sys/$ORACLE_PWD as SYSDBA;' <\
#  $ORAPOC_SETUP_RESOURCES/database-scripts/setup-dbzuser-and-supplemental.sql