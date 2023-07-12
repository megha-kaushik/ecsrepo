locals {

 tags = {

   
    Environment     = "Global"
   
    ServiceProvider = "Megha"
    Terraform       = "true"
  }

all_ingress_rules = [{
  from_port = 80,
  to_port = 80,
  protocol = "tcp",
  description = "To allow connectivity to port 80"
  cidr_blocks =  ["0.0.0.0/0"]
  security_groups = [] 
}, 
{
  from_port = 22,
  to_port = 22,
  protocol = "tcp",
  description = "To allow connectivity at port 22"
  cidr_blocks = ["0.0.0.0/0"]
  security_groups = [] 
}]

all_ingress_db_rules = [{
  from_port = 3306,
  to_port = 3306,
  protocol = "tcp",
  description = "To allow connecitivity to port 3306"
  cidr_blocks =  []
  security_groups = ["${aws_security_group.mysecuritygroup.id}"] 

}]
}