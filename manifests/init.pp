class mcollective {

  $psk            = "unset"
  $stomp_user     = "mcollective"
  $stomp_password = "marionette"
  $stomp_host     = "fqdn"
  $stomp_port     = "6163"
  $factsource     = "facter"

  include mcollective::service
}
