variable "db_allocated_storage" {
}

variable "db_instance_class" {
}

variable "db_engine_version" {
}

variable "db_name" {
}

variable "db_username" {
}

variable "db_password" {
}

variable "db_subnet_group_name" {
}

variable "db_identifier" {
}

variable "db_skip_final_snapshot" {
    default = true
}

variable "rds_sg" {
    type = list(string)
}