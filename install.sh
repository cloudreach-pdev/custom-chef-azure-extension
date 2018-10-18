#!/bin/bash

set -e

if [ -e /etc/chef/client.pem ]
then
    exit 1
fi

/usr/bin/mkdir -p /etc/chef
/usr/bin/mkdir -p /var/lib/chef
/usr/bin/mkdir -p /var/log/chef

/usr/bin/curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v $1

if [ "$3" ]
then
    /usr/bin/echo "{\"run_list\":[\"$3\"]}" > /etc/chef/first-boot.json
else
    /usr/bin/echo "{}" > /etc/chef/first-boot.json
fi

/usr/bin/echo "log_location \"/var/log/chef/chef-client.log\"" >> /etc/chef/client.rb
/usr/bin/echo "chef_server_url \"$4\"" >> /etc/chef/client.rb
/usr/bin/echo "validation_client_name \"$5\"" >> /etc/chef/client.rb
/usr/bin/echo "ssl_verify_mode :verify_peer" >> /etc/chef/client.rb
/usr/bin/echo "client_key \"/etc/chef/client.pem\"" >> /etc/chef/client.rb
/usr/bin/echo "validation_key \"/etc/chef/validation.pem\"" >> /etc/chef/client.rb

/usr/bin/echo $6 | /usr/bin/base64 --decode > /etc/chef/validation.pem

if [ "$7" ]
then
  /usr/bin/echo "node_name \"$7\"" >> /etc/chef/client.rb
fi

sudo chef-client -j /etc/chef/first-boot.json --environment $2

set +e
