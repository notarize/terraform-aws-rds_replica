###############################################################################
# Outputs
# terraform output summary
###############################################################################

output "summary" {
  value = <<EOF
## Outputs
| db_endpoint               | ${module.rds_master.db_endpoint} |
| db_endpoint_address       | ${module.rds_master.db_endpoint_address} |
| db_endpoint_port          | ${module.rds_master.db_endpoint_port} |
| db_instance               | ${module.rds_master.db_instance} |
| db_instance_arn           | ${module.rds_master.db_instance_arn} |
| jdbc_connection_string    | ${module.rds_master.jdbc_connection_string} |
| monitoring_role           | ${module.rds_master.monitoring_role} |
| option_group              | ${module.rds_master.option_group} |
| parameter_group           | ${module.rds_master.parameter_group} |
| subnet_group              | ${module.rds_master.subnet_group} |
EOF

  description = "ec2_asg output summary"
}
