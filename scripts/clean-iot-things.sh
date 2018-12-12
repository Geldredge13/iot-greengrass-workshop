#!/bin/bash

echo -e "\nStarting the IOT cleanup process \n"
echo -n "Enter name of the first device > "
read response
if [ -n "$response" ]; then
    thing_Name1=$response
fi
echo -n "Enter name of the second device > "
read response
if [ -n "$response" ]; then
    thing_Name2=$response
fi
echo -n "Enter device type > "
read response
if [ -n "$response" ]; then
    thing_Type=$response
fi

if [ [-z "$thing_Name1"] || [-z "$thing_Name2"] || [-z "$thing_type"]]; then
        echo -e "\n Usage $0 Device1 Device2 DeviceType\n"
        exit 0
fi

#Deleting device 1 certificates and policies
echo -e "\nCleaning up the artifacts for device $thing_Name1\n"
prin=$(aws iot list-thing-principals --thing-name $thing_Name1 | jq -r '.principals[]')
cert_id=$(echo $prin | sed -e 's|.*/||')
echo -e "\nDetaching the principal $prin from the device $thing_Name1\n"
aws iot detach-thing-principal --thing-name $thing_Name1 --principal $prin
echo -e "\nUpdating the certificate to be Inactive\n"
aws iot update-certificate --new-status INACTIVE --certificate-id $cert_id
pol_name=$(aws iot list-principal-policies --principal $prin | jq -r '.policies[].policyName')
echo -e "\nDetaching the policy $pol_name from the principal $prin\n"
aws iot detach-policy --policy-name $pol_name --target $prin
echo -e "\nDeleting the certificates $cert_id\n"
aws iot delete-certificate --certificate-id $cert_id
echo -e "\nDeleting the device $thing_Name1\n"
aws iot delete-thing --thing-name $thing_Name1

sleep 3
#Deleting device 2 certificates and policies
echo -e "\nCleaning up the artifacts for device $thing_Name2\n"
prin=$(aws iot list-thing-principals --thing-name $thing_Name2 | jq -r '.principals[]')
cert_id=$(echo $prin | sed -e 's|.*/||')
echo -e "\nDetaching the principal $prin from the device $thing_Name2\n"
aws iot detach-thing-principal --thing-name $thing_Name2 --principal $prin
echo -e "\nUpdating the certificate to be Inactive\n"
aws iot update-certificate --new-status INACTIVE --certificate-id $cert_id
pol_name=$(aws iot list-principal-policies --principal $prin | jq -r '.policies[].policyName')
echo -e "\nDetaching the policy $pol_name from the principal $prin\n"
aws iot detach-policy --policy-name $pol_name --target $prin
echo -e "\nDeleting the certificates $cert_id\n"
aws iot delete-certificate --certificate-id $cert_id
echo -e "\nDeleting the device $thing_Name1\n"
aws iot delete-thing --thing-name $thing_Name2
echo -e "\nDeleting the keys and certificates\n"
rm -rf ./$thing_Name1/ ./$thing_Name2/

#Deleting the policy
policy_Name="edworkshop-policy"
echo -e "\nDeleting the policy $pol_name\n"
aws iot delete-policy --policy-name $policy_Name
echo -e "\nDeprecate the thing type $thing_Type\n"
aws iot deprecate-thing-type --thing-type-name $thing_Type
sleep 3
echo -e "\n Cleanup of IOT resources complete \n"