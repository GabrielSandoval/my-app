resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "my_app_service_sg" {
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "my_app_service" {
  name                              = "my_app_web_service"     # Name the service
  cluster                           = "${aws_ecs_cluster.my_app_cluster.id}"   # Reference the created Cluster
  task_definition                   = "${aws_ecs_task_definition.my_app_web.arn}" # Reference the task that the service will spin up
  launch_type                       = "FARGATE"
  desired_count                     = 1 # Set up the number of containers to 2
  health_check_grace_period_seconds = 300 # 5 minutes

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
    container_name   = "${aws_ecs_task_definition.my_app_web.family}"
    container_port   = 3000 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.my_app_service_sg.id}"] # Set up the security group
  }
}

resource "aws_ecs_service" "my_app_db_create" {
  name            = "my_app_db_create"     # Name the task
  cluster         = "${aws_ecs_cluster.my_app_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.my_app_db_create.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  count           = 1 # Set up the number of containers to 1

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = false
    security_groups  = ["${aws_security_group.my_app_service_sg.id}"] # Set up the security group
  }
}

resource "aws_ecs_service" "my_app_db_migrate" {
  name            = "my_app_db_migrate"     # Name the task
  cluster         = "${aws_ecs_cluster.my_app_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.my_app_db_migrate.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  count           = 1 # Set up the number of containers to 1

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = false
    security_groups  = ["${aws_security_group.my_app_service_sg.id}"] # Set up the security group
  }
}
