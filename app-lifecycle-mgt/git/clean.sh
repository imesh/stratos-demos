#!/bin/bash

dev="stratos-app-lcmgt-demo-dev"
test="stratos-app-lcmgt-demo-test"

pushd application/employee
mvn clean
popd

if [ -d ${dev} ]; then
	rm -rf ${dev}/
fi

if [ -d ${test} ];  then
	rm -rf ${test}/ 
fi
