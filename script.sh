#!/bin/bash

latest_file=`ls -t * | egrep "(.*\.xml|.*\.sql|.*\.yaml|.*\.json)"|head -1`
mkdir -p dist
rm -f dist/*
/bin/cp -vfr $latest_file dist/

#action='update'
#echo $latest_file | grep "rollback" && action='rollback'
author=`git log --pretty=format:"%an" |tail -1`
#commit=`git log | tail -1 | sed 's/^ *//'`

sql_file=`ls -t * | egrep "(.*\.sql)"|tail -1`
xml_file=`ls -t * | egrep "(.*\.xml)"|tail -1`
yaml_file=`ls -t * | egrep "(.*\.yaml)"|tail -1`
json_file=`ls -t * | egrep "(.*\.json)"|tail -1`

#for SQL changesets
if [ "$sql_file" == "$latest_file" ]
then
	echo "SQL format file has latest changes"
	sed -i "s/--changeset.*/--changeset $author:${BUILD_NUMBER}/" dist/$latest_file
#for XML changesets
elif [ "$xml_file" == "$latest_file" ]
then
	echo "XML format file has latest changes"
	sed -i  "s/<changeSet id.*/<changeSet id=\"${BUILD_NUMBER}\" author=\"$author\">/" dist/$latest_file

#for YAML changesets
elif [ "$yaml_file" == "$latest_file" ]
then
	echo "YAML format file has latest changes"
	sed -i "s/id:.*/id: ${BUILD_NUMBER}/" dist/$latest_file
	sed -i "s/author:.*/author: $author/" dist/$latest_file
#for JSON changesets
elif [ "$json_file" == "$latest_file" ]
then
	echo "JSON format file has latest changes"
	sed -i "s/\"id\":.*/\"id\": \"${BUILD_NUMBER}\",/" dist/$latest_file
	sed -i "s/\"author\":*/\"author\": \"$author\",/" dist/$latest_file
fi



echo "------> Executing Liquibase <------"
cd /opt/liquibase_app/
java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/$latest_file --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST update
java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/$latest_file --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST tag ${BUILD_NUMBER}


#java -jar liquibase.jar --classpath=/opt/oracle/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar --username=system --password=system --changeLogFile=${WORKSPACE}/dist/${latest_file} --driver=oracle.jdbc.OracleDriver --url=jdbc:oracle:thin:@localhost:1521:TEST rollback ${BUILD_NUMBER}


