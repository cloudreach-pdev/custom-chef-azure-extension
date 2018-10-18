#!/bin/bash

set -e

# If chef already exists on the node then we don't want to overwrite settings
if [ -e /etc/chef/client.pem ]
then
    exit 0;
fi

mkdir -p /etc/chef
mkdir -p /var/lib/chef
mkdir -p /var/log/chef

curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v $1

if [ "$3" ]
then
    echo "{\"run_list\":[\"$3\"]}" > /etc/chef/first-boot.json
else
    echo "{}" > /etc/chef/first-boot.json
fi

echo "log_location \"/var/log/chef/chef-client.log\"" >> /etc/chef/client.rb
echo "chef_server_url \"$4\"" >> /etc/chef/client.rb
echo "validation_client_name \"$5\"" >> /etc/chef/client.rb
echo "ssl_verify_mode :verify_peer" >> /etc/chef/client.rb
echo "client_key \"/etc/chef/client.pem\"" >> /etc/chef/client.rb
echo "validation_key \"/etc/chef/validation.pem\"" >> /etc/chef/client.rb

echo $6 | base64 --decode > /etc/chef/validation.pem

if [ "$7" ]
then
    echo "node_name \"$7\"" >> /etc/chef/client.rb
fi

sudo chef-client -j /etc/chef/first-boot.json --environment $2

set +e
