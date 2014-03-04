# === Class: moodle::params
#
#  The WSO2greg configuration settings idiosyncratic to different operating
#  systems.
#
# === Parameters
#
# None
#
# === Examples
#
# None
#
# === Authors
#
# Luca Gioppo <gioppoluca@libero.it>
#
# === Copyright
#
# Copyright 2012 Luca Gioppo
#
class wso2esb::params {

$db_type            = "h2"
  $db_host            = "wso2mysql.$::domain"
  $db_name            = 'odaiesb'
  $db_user            = 'odaiesb'
  $db_password        = 'odaiesb1'
  $db_tag = 'esb_db'
  $download_site      = 'http://dist.wso2.org/products/governance-registry/'
  $product_name       = 'wso2esb'
  $admin_password       = 'admin'
  $external_greg = 'false'
  $greg_server_url = "localhost"
  $greg_db_host = "localhost"
  $greg_db_name = 'WSO2CARBON_DB'
  $greg_db_type = "h2"
  $greg_username = "admin"
  $greg_password = "admin"
}
