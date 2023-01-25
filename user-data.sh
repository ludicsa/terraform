#!/bin/bash
nohup java -jar /opt/deployment/myapp.jar --server.port=8080 > /var/log/apps/myapp.log 2>&1 &