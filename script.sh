#!/usr/bin/bash

latest_file='$(ls -t * | egrep "(.*\.xml|.*\.sql|.*\.yaml|.*\.json)"|head -1)'
mkdir -p dist
rm -f dist/*
/bin/cp -vfr $latest_file dist/

action='update'
#echo $latest_file | grep "rollback" && action='rollback'
author=`git log --pretty=format:"%an" |tail -1`
#commit=`git log | tail -1 | sed 's/^ *//'`



#for SQL changesets
sed -i "s/--changeset.*/--changeset $author:${BUILD_NUMBER}/" dist/$latest_file
#for XML changesets
sed -i  "s/<changeSet id.*/<changeSet id=\"${BUILD_NUMBER}\" author=\"$author\">/" dist/$latest_file
#for YAML changesets
sed -i "s/id:.*/id: ${BUILD_NUMBER}/" dist/$latest_file
sed -i "s/author:.*/author: $author/" dist/$latest_file
#for JSON changesets
sed -i "s/\"id\":.*/\"id\": \"${BUILD_NUMBER}\",/" dist/$latest_file
sed -i "s/\"author\":*/\"author\": \"$author\",/" dist/$latest_file


echo "------> Executing Liquibase <------"
cd /opt/liquibase_app/
java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/$latest_file --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST update
java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/$latest_file --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST tag ${BUILD_NUMBER}


#java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/${latest_file} --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST rollback ${BUILD_NUMBER}


