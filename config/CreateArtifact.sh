#!/bin/bash
#### Create folder structure and copy existing files ####
echo "Copying important files..."
mkdir -pv DPMS_RC
mkdir -pv DPMS_RC/config && cp -r config/agents config/certs DPMS_RC/config/ 
mkdir -pv DPMS_RC/scripts && cp -r scripts/install-scripts DPMS_RC/scripts/
#### Package ####
echo "Packaging..."
tar -czvf DPMS_RC.tar.gz ./DPMS_RC
echo "Cleaning up..."
rm -rf DPMS_RC
echo "Done!"