#!/bin/bash

set -e

src="stratos-demo-src/employee"
test="stratos-demo-test"

pushd $src
echo "Building application ..."
mvn clean install
popd

echo "Copying application war file to test git repo ..."
cp -f $src/target/employee-0.1.0.BUILD-SNAPSHOT.war $test/employee.war
pushd $test

echo "Adding application war file to test git repo ..."
git add employee.war
echo "Committing changes ..."
git commit -m "Added latest employee.war to test"
echo "Sending changes to remote test git repo ..."
git push origin master
