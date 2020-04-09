#!/bin/bash
kubectl patch pv $(kubectl get pv | grep elasticsearch | awk '{print $1}')  -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'