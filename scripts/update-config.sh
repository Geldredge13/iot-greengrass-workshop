#!/bin/bash

echo -e "\nUpdating the configs for Greengrass & IOT Analytics :\n"
thing_Name=ggsummitcore
echo -n "Enter the region you are working on us-east-1 or us-west-2 > "
read response
if [ -n "$response" ]; then
    reg_Name=$response
fi

if [ -z "$reg_Name" ]; then
        echo -e "\n Usage $0 region \n"
        exit 0
fi
#Updating the config for Greengrass
prin=$(aws iot list-thing-principals --thing-name $thing_Name | jq -r '.principals[]' | awk -F":" '{print $5}')
sed -i "s/xxxxxxxxxxxx/$prin/" config-$reg_Name.json
sed -i "s/xxxxxxxxxxxx/$prin/" ./iotanalytics/*.json
echo -e "\nCopying the config to /greengrass/config\n"
cp ggsummitcore* /greengrass/certs
echo -e "\nCopying the greengrass core certificates to /greengrass/certs\n"
cp config-$reg_Name.json /greengrass/config/config.json
echo -e "\nAssociating Greengrass Role to Account\n"
aws greengrass associate-service-role-to-account --role-arn arn:aws:iam::$prin:role/EDGreengrassRole
echo -e "\nAdding permission for IOT Analytics to invoke Lambda\n"
aws lambda add-permission --function-name analyticslambda --statement-id iot --principal iotanalytics.amazonaws.com --action lambda:InvokeFunction
echo -e "\nAdding version to the edge lambda function for deploying to greengrass\n"
aws lambda publish-version --function-name edgelambda --description 1