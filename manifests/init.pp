class mcollective::common {

  $mcollective_psk            = create_and_print_password("mcollective-psk")
  $mcollective_stomp_user     = "mcollective"
  $mcollective_stomp_password = create_and_print_password("activemq-general-mcollective-password")
  $mcollective_stomp_host     = "sinla011.sin.infineon.com"
  $mcollective_stomp_port     = "61613"
  $mcollective_factsource     = "facter"

  include mcollective::service
}
