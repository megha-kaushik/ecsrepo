################### s3 buckets ############################

resource "aws_s3_bucket" "my_bucket" {
 
  bucket = "${var.region_alias}-${var.country}-${var.account_alias}-${var.bucketname}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }
    
  
  
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {

  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
 


}

################ EC2 instance ##################

resource "aws_instance" "myinstance" {
  count = 2
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  associate_public_ip_address = "true"
  subnet_id = var.subnet_id
  key_name  = var.key_name
  vpc_security_group_ids = ["${aws_security_group.mysecuritygroup.id}"]
  tags = merge(
    {
      Name = try(
         "${var.region_alias}-${var.country}-${var.account_alias}-${var.ec2machine}-${count.index}"
      )
    },
    local.tags
  )
}


 resource "aws_security_group" "mysecuritygroup" {
  name        = "${var.region_alias}-${var.country}-${var.account_alias}-${var.securitygroup}"
  description = "Allow communication from  these ports"
  vpc_id      = var.vpc_id

 dynamic "ingress" {
    for_each = local.all_ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      description      = ingress.value.description
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_groups
     
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

tags = local.tags
}


############### rds instance #################


resource "aws_db_instance" "myrds" {
  allocated_storage           = 20
  auto_minor_version_upgrade  = true                       
  db_name = var.db_name
  backup_retention_period     = 7
  vpc_security_group_ids = ["${aws_security_group.dbsecuritygroup.id}"]

  engine                      = "mysql"
  engine_version              = "5.7"
  port     = "3306"
  identifier                  = "${var.region_alias}-${var.country}-${var.account_alias}-${var.dbinstance}"
  instance_class              = var.instance_class 
  deletion_protection = true
 
  multi_az                    = false
  password                    = var.password
  username                    = var.username
  storage_encrypted           = true

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}


resource "aws_security_group" "dbsecuritygroup" {
  name        = "${var.region_alias}-${var.country}-${var.account_alias}-${var.dbsecuritygroup}"
  description = "Allow communication from  these ports"
  vpc_id      = var.vpc_id

 dynamic "ingress" {
    for_each = local.all_ingress_db_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      description      = ingress.value.description
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_groups
     
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

tags = local.tags
}


############### redshift #####################

resource "redshift_database" "db_redshift" {
  name = "${var.region_alias}-${var.country}-${var.account_alias}-${var.redshift_name}"
  owner = "my_user"
  connection_limit = 123456

  lifecycle {
    prevent_destroy = true
  }
}