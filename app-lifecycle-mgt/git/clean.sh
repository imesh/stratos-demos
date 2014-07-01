#!/bin/bash

pushd stratos-demo-src/employee
mvn clean
popd

pushd stratos-demo-src/employee-h2
mvn clean
popd