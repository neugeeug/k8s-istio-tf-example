aws_region = "us-east-1"

vpc_id = "vpc-EXAMPLE"

private_subnet_ids = [
  "subnet-EXAMPLE1",
  "subnet-EXAMPLE2"
]

allowed_security_group_ids = [
  "sg-EXAMPLE_APP_CLUSTER"
]

# allowed_cidr_blocks = ["10.0.0.0/16"]

db_instance_class = "db.t3.micro"
db_allocated_storage = 20
multi_az = false

