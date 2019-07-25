####################################################################################################
# MySQL Master                                                                                   #
####################################################################################################

module "rds_master" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"

  ##################
  # Required Configuration
  ##################
  subnets           = module.vpc.private_subnets #  Required
  security_groups   = [module.vpc.default_sg]    #  Required
  name              = "sample-mysql-rds"         #  Required
  engine            = "mysql"                    #  Required
  instance_class    = "db.t2.large"              #  Required
  storage_encrypted = true                       #  Parameter defaults to false, but enabled for Cross Region Replication example
  # username = "dbadmin"
  password = "${data.aws_kms_secrets.rds_credentials.plaintext["password"]}" #  Required

  ##################
  # VPC Configuration
  ##################

  #   create_subnet_group   = true
  #   existing_subnet_group = "some-subnet-group-name"

  ##################
  # Backups and Maintenance
  ##################

  #   maintenance_window      = "Sun:07:00-Sun:08:00"
  #   backup_retention_period = 35
  #   backup_window           = "05:00-06:00"
  #   db_snapshot_id          = "some-snapshot-id"

  ##################
  # Basic RDS
  ##################

  #   dbname                = "mydb"
  #   engine_version        = "5.7.19"
  #   port                  = "3306"
  #   copy_tags_to_snapshot = true
  #   timezone              = "US/Central"
  #   storage_type          = "gp2"
  #   storage_size          = 10
  #   storage_iops          = 0

  ##################
  # RDS Advanced
  ##################

  #   publicly_accessible           = false
  #   auto_minor_version_upgrade    = true
  #   family                        = "mysql5.7"
  #   multi_az                      = false
  #   storage_encrypted             = false
  #   kms_key_id                    = "arn:aws:kms:us-west-2:12345678910:key/44ff8a34-FFFF-FFFF-FFFF-ecba974a44ca"
  #   parameters                    = []
  #   create_parameter_group        = true
  #   existing_parameter_group_name = "some-parameter-group-name"
  #   options                       = []
  #   create_option_group           = true
  #   existing_option_group_name    = "some-option-group-name"

  ##################
  # RDS Monitoring
  ##################

  #   notification_topic       = aws_sns_topic.my_test_sns.arn
  #   alarm_write_iops_limit   = 100
  #   alarm_read_iops_limit    = 100
  #   alarm_free_space_limit   = 1024000000
  #   alarm_cpu_limit          = 60
  #   monitoring_interval      = 0
  #   existing_monitoring_role = ""

  ##################
  # Other parameters
  ##################

  #   environment = "Development"

  #   tags = {
  #     SomeTag = "SomeValue"
  #   }
}

####################################################################################################
# MySQL Same Region Replica                                                                     #
####################################################################################################

module "rds_replica" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"

  ##################
  # Required Configuration
  ##################

  subnets                       = "${module.vpc.private_subnets}" #  Required
  security_groups               = ["${module.vpc.default_sg}"]    #  Required
  create_subnet_group           = false
  existing_subnet_group         = "${module.rds_master.subnet_group}"
  name                          = "sample-mysql-rds-rr" #  Required
  engine                        = "mysql"               #  Required
  instance_class                = "db.t2.large"         #  Required
  storage_encrypted             = true                  #  Parameter defaults to false, but enabled for Cross Region Replication example
  create_parameter_group        = false
  existing_parameter_group_name = "${module.rds_master.parameter_group}"
  create_option_group           = false
  existing_option_group_name    = "${module.rds_master.option_group}"
  read_replica                  = true
  source_db                     = "${module.rds_master.db_instance}"
  password                      = "" #  Retrieved from source DB

  ##################
  # Backups and Maintenance
  ##################

  # maintenance_window      = "Sun:07:00-Sun:08:00"
  # backup_retention_period = 35
  # backup_window           = "05:00-06:00"
  # db_snapshot_id          = "some-snapshot-id"

  ##################
  # Basic RDS
  ##################

  # dbname                = "mydb"
  # engine_version        = "5.7.19"
  # port                  = "3306"
  # copy_tags_to_snapshot = true
  # timezone              = "US/Central"
  # storage_type          = "gp2"
  # storage_size          = 10
  # storage_iops          = 0

  ##################
  # RDS Advanced
  ##################

  # publicly_accessible           = false
  # auto_minor_version_upgrade    = true
  # family                        = "mysql5.7"
  # multi_az                      = false
  # storage_encrypted             = false
  # kms_key_id                    = "some-kms-key-id"
  # parameters                    = []
  # options                       = []

  ##################
  # RDS Monitoring
  ##################

  # notification_topic           = "arn:aws:sns:<region>:<account>:some-topic"
  # alarm_write_iops_limit       = 100
  # alarm_read_iops_limit        = 100
  # alarm_free_space_limit       = 1024000000
  # alarm_cpu_limit              = 60
  # rackspace_alarms_enabled      = true
  # monitoring_interval          = 0
  # existing_monitoring_role = ""

  ##################
  # Other parameters
  ##################

  # environment = "Production"

  # tags = {
  #   SomeTag = "SomeValue"
  # }
}

####################################################################################################
# MySQL Cross Region Replica                                                                     #
####################################################################################################


module "rds_cross_region_replica" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"

  providers = {
    aws = "aws.sydney"
  }

  #######################
  # Required parameters #
  #######################

  subnets           = "${module.vpc_dr.private_subnets}"        #  Required
  security_groups   = ["${module.vpc_dr.default_sg}"]           #  Required
  name              = "sample-mysql-rds-crr"                    #  Required
  engine            = "mysql"                                   #  Required
  instance_class    = "db.t2.large"                             #  Required
  storage_encrypted = true                                      #  Parameter defaults to false, but enabled for Cross Region Replication example
  kms_key_id        = data.aws_kms_alias.rds_crr.target_key_arn # Parameter needed since we are replicating an db instance with encrypted storage.
  password          = ""                                        #  Retrieved from source DB
  read_replica      = true
  source_db         = module.rds_master.db_instance_arn

  ##################
  # VPC Configuration
  ##################

  # create_subnet_group   = true
  # existing_subnet_group = "some-subnet-group-name"

  ##################
  # Backups and Maintenance
  ##################

  # maintenance_window      = "Sun:07:00-Sun:08:00"
  # backup_retention_period = 35
  # backup_window           = "05:00-06:00"
  # db_snapshot_id          = "some-snapshot-id"

  ##################
  # Basic RDS
  ##################

  # dbname                = "mydb"
  # engine_version        = "5.7.19"
  # port                  = "3306"
  # copy_tags_to_snapshot = true
  # timezone              = "US/Central"
  # storage_type          = "gp2"
  # storage_size          = 10
  # storage_iops          = 0

  ##################
  # RDS Advanced
  ##################

  # publicly_accessible           = false
  # auto_minor_version_upgrade    = true
  # family                        = "mysql5.7"
  # multi_az                      = false
  # storage_encrypted             = false
  # kms_key_id                    = "some-kms-key-id"
  # parameters                    = []
  # create_parameter_group        = true
  # existing_parameter_group_name = "some-parameter-group-name"
  # options                       = []
  # create_option_group           = true
  # existing_option_group_name    = "some-option-group-name"

  ##################
  # RDS Monitoring
  ##################

  # notification_topic           = "arn:aws:sns:<region>:<account>:some-topic"
  # alarm_write_iops_limit       = 100
  # alarm_read_iops_limit        = 100
  # alarm_free_space_limit       = 1024000000
  # alarm_cpu_limit              = 60
  # rackspace_alarms_enabled      = true
  # monitoring_interval          = 0
  # existing_monitoring_role = ""

  ##################
  # Other parameters
  ##################

  # environment = "Production"

  # tags = {
  #   SomeTag = "SomeValue"
  # }
}