/* subnet used by rds */
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
  ]
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = "${aws_default_vpc.default_vpc.id}"
  name        = "rds-db-access-sg"
  description = "Allow access to RDS"
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security Group"
  vpc_id      = "${aws_default_vpc.default_vpc.id}"

  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow traffic for TCP 3306
  ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.db_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "my-app-db"
  allocated_storage      = "5"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t4g.micro"
  multi_az               = true

  db_name                = "my_app_production"
  username               = "my_app_production"
  password               = "my_app_production"

  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true
}