#!/bin/bash

set -e

src="stratos-demo-src/employee"
dev="stratos-demo-dev"

pushd $src
echo "Building application ..."
mvn clean install
popd

echo "Copying application war file to dev git repo ..."
cp -f $src/target/employee-0.1.0.BUILD-SNAPSHOT.war $dev/employee.war
pushd $dev

echo "Adding application war file to dev git repo ..."
git add employee.war
echo "Committing changes ..."
git commit -m "Added latest employee.war to dev"
echo "Sending changes to remote dev git repo ..."
git push origin master
