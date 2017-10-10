#!/bin/bash

export OUSER=$(id -u)
export OGROUP=$(id -g)

package_root_dir="/var/www"

sudo -u root /bin/bash << EOS

apt-get update
apt-get install -y lighttpd rpm2cpio
ln -s /etc/lighttpd/conf-available/10-dir-listing.conf /etc/lighttpd/conf-enabled/
sed -i 's#\(server.document-root\)[ \t]*=.*#\1 = "'$package_root_dir'"#' /etc/lighttpd/lighttpd.conf
service lighttpd restart
chown -R $OUSER /var/www
chgrp -R $OGROUP /var/www

EOS

contrail_version=${CONTRAIL_VERSION:-4.0.1.0-32}
os_versions=(ocata newton pike)
s3_bucket_url="https://s3-us-west-2.amazonaws.com/contrailrhel7"

for os_version in ${os_versions[@]}:
do
  package_url=$s3_bucket_url/contrail-install-packages-$contrail_version~$os_version.el7.noarch.rpm
  http_status=$(curl -Isw "%{http_code}" -o /dev/null $package_url)
  if [ $http_status == "200" ]; then
    break
  fi
done

if [ $http_status != "200" ]; then
  echo No Contrail packages found for version $contrail_version
  exit
fi

package_fname=$(mktemp)
echo Getting $package_url to $package_fname
curl -o $package_fname $package_url

package_dir=$(mktemp -d)
pushd $package_dir
echo $package_dir
rpm2cpio $package_fname | cpio -idmv
popd

repo_dir=$package_root_dir/$contrail_version
if [ -d $repo_dir ]; then
  echo Remove existing packages in $repo_dir
  rm -rf $repo_dir
fi
echo Extract packages to $repo_dir
mkdir $repo_dir
tar -xvzf $package_dir/opt/contrail/contrail_packages/contrail_rpms.tgz -C $repo_dir

rm -rf $package_dir
rm $package_fname
