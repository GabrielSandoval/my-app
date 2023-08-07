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

resource "aws_ecs_service" "my_app_service" {
  name            = "my_app_service"     # Name the service
  cluster         = "${aws_ecs_cluster.my_app_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.my_app_task.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 2 # Set up the number of containers to 2

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
    container_name   = "${aws_ecs_task_definition.my_app_task.family}"
    container_port   = 3000 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}

resource "aws_ecs_task_definition" "my_app_task" {
  family                   = "my_app_task" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my_app_task",
      "image": "${aws_ecr_repository.my_app_repo.repository_url}",
      "essential": true,
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.my_app.name}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "web"
        }
      },
      "environment": [
        {
          "name": "RAILS_ENV",
          "value": "production"
        },
        {
          "name": "HOST",
          "value": "${aws_alb.my_app_load_balancer.dns_name}"
        },
        {
          "name": "DATABASE_HOST",
          "value": "${aws_db_instance.rds.address}"
        },
        {
          "name": "DATABASE_NAME",
          "value": "${aws_db_instance.rds.db_name}"
        },
        {
          "name": "DATABASE_USERNAME",
          "value": "${aws_db_instance.rds.username}"
        },
        {
          "name": "DATABASE_PASSWORD",
          "value": "${aws_db_instance.rds.password}"
        }
      ],
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
}

# I was initially gettting this:
# ActiveRecord::DatabaseConnectionError (There is an issue connecting with your hostname: my-app-db.cbbxmhkhubl8.us-east-1.rds.amazonaws.com:3306.
#
# Then after removing the port from the database endpoint, I now get this:
# ActiveRecord::ConnectionNotEstablished (Can't connect to server on 'my-app-db.cbbxmhkhubl8.us-east-1.rds.amazonaws.com' (110)):
