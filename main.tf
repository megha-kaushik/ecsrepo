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
  subnet_id = data.aws_subnet.mysubnet.id
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

########### data source for vpc_id #####

data "aws_vpc" "myvpc" {
  id = var.vpc_id
}
######## data source for subnet ########

data "aws_subnet" "mysubnet" {
  id = var.subnet_id
}


 resource "aws_security_group" "mysecuritygroup" {
  name        = "${var.region_alias}-${var.country}-${var.account_alias}-${var.securitygroup}"
  description = "Allow communication from  these ports"
  vpc_id      = data.aws_vpc.myvpc.id

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
  vpc_id      = data.aws_vpc.myvpc.id
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

###################### autoscaling group and launch template ################


### data source for retrieving ami-id

data "aws_ami" "goldenami" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "tag:Name"
    values = ["mygoldenimage"]
  }

   owners = ["586869554856"]

}

resource "aws_launch_template" "launch_conf" {
  name          = "${var.region_alias}-${var.country}-${var.account_alias}-${var.launchconfig}"
  image_id      = data.aws_ami.goldenami.id
  instance_type =  var.launchinstancetype

  network_interfaces {
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.mysecuritygroup.id}"]
  }

  key_name  = var.key_name
#   vpc_security_group_ids = ["${aws_security_group.mysecuritygroup.id}"]

  lifecycle {
    create_before_destroy = true
  }

  

}

########## autoscaling group ##########

resource "aws_autoscaling_group" "myautoscaling" {
  name                 = "${var.region_alias}-${var.country}-${var.account_alias}-${var.autoscalinggroup}"
  
  launch_template {
    id     = aws_launch_template.launch_conf.id
    version = "$Latest"
  }
  availability_zones = ["us-east-1a","us-east-1b"]
  health_check_type         = "EC2"
  health_check_grace_period = 60
  desired_capacity          = 1
  force_delete              = true
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }


}


resource "aws_autoscaling_policy" "mypolicy" {
  name                   = "${var.region_alias}-${var.country}-${var.account_alias}-${var.autoscalinggrouppolicy}"

  adjustment_type        = "ChangeInCapacity"
  policy_type =           "TargetTrackingScaling"
  estimated_instance_warmup = 60
#   cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.myautoscaling.name
 

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 81.0
  }

  

}

####################  code for redshift #############

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}


resource "aws_redshift_cluster" "example" {
  cluster_identifier = "${var.region_alias}-${var.country}-${var.account_alias}-${var.redshiftcluser}"
  database_name      = "myredshiftdb"
  master_username    = var.username
  master_password    = random_password.password.result
  node_type          = var.nodetype
  cluster_type       = "single-node"
  skip_final_snapshot = true
}