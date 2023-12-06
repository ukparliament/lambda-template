
# locals {
#   pghost = data.aws_ssm_parameter.db_instance_address.value
#   pgport = data.aws_ssm_parameter.db_instance_port.value
#   pgdatabase = data.aws_ssm_parameter.db_database_name.value
# }
# data "aws_ssm_parameter" "db_instance_address" {
#   name  = "${var.rds_output_prefix}/db_instance_address"
# }
# data "aws_ssm_parameter" "db_instance_port" {
#   name  = "${var.rds_output_prefix}/db_instance_port"
# }
# data "aws_ssm_parameter" "db_database_name" {
#   name  = "${var.rds_output_prefix}/db_database_name"
# }