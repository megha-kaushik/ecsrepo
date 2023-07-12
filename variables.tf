variable "bucketname" {
  description = "Name of the bucket to be created."
  type        = string
}

variable "account_alias" {
  description = "Name of the account alias to be used for prod account "
  type        = string
  default     = ""
}

variable "region_alias" {
  description = "Name of the region alias to be used"
  type        = string
  default     = ""
}

variable "country" {
  description = "Name of the country where the infrastructure need to be build"
  type        = string
  default     = ""
}

variable "securitygroup" {
  description = "Name of the securitygroup"
  type        = string
  default     = ""
}

################## ec2 variables ##################

variable "ami" {
  description = "ami id to be added with instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "type of the instance "
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = "name of the availability zone"
  type        = string
  default     = ""
}


variable "subnet_id" {
  description = "subnet id to be added"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "key name associated with ec2 instance "
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "Name of the vpc id to be associated with security group "
  type        = string
  default     = ""
}


variable "tags" {
  description = "Tags to be used"
  type        = map(string)
  default     = {}
}

variable "ec2machine" {
  description = "Name of the ec2 machine created"
  type        = string
  default     = ""
}

############# db #################

variable "instance_class" {
  description = "instance class used"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Name of the db inside rds"
  type        = string
  default     = ""
}

variable "password" {
  description = "Name of the password for db"
  type        = string
  default     = ""
}

variable "username" {
  description = "Name of the username for db"
  type        = string
  default     = ""
}

variable "dbinstance" {
  description = "Name of the db instance name  created"
  type        = string
  default     = ""
}

variable "dbsecuritygroup" {
  description = "Name of the dbsecuritygroup"
  type        = string
  default     = ""
}

variable "redshift_name" {
  description = "Name of the redshift name"
  type        = string
  default     = ""
}