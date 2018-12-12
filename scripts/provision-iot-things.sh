#!/bin/bash
echo -e "\nStarting the IOT Registration process \n"
echo -n "Enter blood pressure sensor name > "
read response
if [ -n "$response" ]; then
	thing_Name1=$response
fi

echo -n "Enter heart rate sensor name > "
read response
if [ -n "$response" ]; then
	thing_Name2=$response
fi

echo -n "Enter device type > "
read response
if [ -n "$response" ]; then
	thing_Type=$response
fi

# create a thing type and things  in the thing registry
echo -e "Creating a thing type \n"
aws iot create-thing-type --thing-type-name $thing_Type
echo -e "Creating the devices $thing_Name1 & $thing_Name2 \n"
aws iot create-thing --thing-name $thing_Name1 --thing-type-name $thing_Type
aws iot create-thing --thing-name $thing_Name2 --thing-type-name $thing_Type
sleep 3

# create key and certificates for your device and activate the device
echo -e "Creating the certificates for device $thing_Name1 & $thing_Name2\n"
aws iot create-keys-and-certificate --set-as-active --public-key-outfile ./$thing_Name1/$thing_Name1.public.key --private-key-outfile ./$thing_Name1/$thing_Name1.private.key --certificate-pem-outfile ./$thing_Name1/$thing_Name1.certificate.pem > /tmp/$thing_Name1.cert_keys

aws iot create-keys-and-certificate --set-as-active --public-key-outfile ./$thing_Name2/$thing_Name2.public.key --private-key-outfile ./$thing_Name2/$thing_Name2.private.key --certificate-pem-outfile ./$thing_Name2/$thing_Name2.certificate.pem > /tmp/$thing_Name2.cert_keys
aws iot list-certificates
sleep 3

# create an IoT policy
policy_Name="edworkshop-policy"
aws iot create-policy --policy-name $policy_Name --policy-document file://policy.json

# attach the policy to your certificate
certificate_Arn1=$(jq -r ".certificateArn" /tmp/$thing_Name1.cert_keys)
certificate_Arn2=$(jq -r ".certificateArn" /tmp/$thing_Name2.cert_keys)
aws iot attach-policy --policy-name $policy_Name --target $certificate_Arn1
aws iot attach-policy --policy-name $policy_Name --target $certificate_Arn2
echo -e "\nThe policy $policy_Name is attached to certificates > \n $certificate_Arn1 && \n $certificate_Arn2 \n"
sleep 3

# attach the certificate to your thing
aws iot attach-thing-principal --thing-name $thing_Name1 --principal $certificate_Arn1
aws iot attach-thing-principal --thing-name $thing_Name2 --principal $certificate_Arn2
echo -e "The certificates are attached to the things > \n"
aws iot list-things --thing-type-name $thing_Type
echo -e "\n IOT Registration complete \n"
