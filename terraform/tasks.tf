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

resource "aws_ecs_task_definition" "my_app_db_create" {
  family                   = "my_app_task_db_create" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my_app_db_create",
      "image": "${aws_ecr_repository.my_app_repo.repository_url}",
      "command": ["bundle", "exec", "rake", "db:create"],
      "essential": true,
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.my_app.name}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "rails"
        }
      },
      "environment": [
        {
          "name": "RAILS_LOG_TO_STDOUT",
          "value": "true"
        },
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

resource "aws_ecs_task_definition" "my_app_db_migrate" {
  family                   = "my_app_task_db_migrate" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my_app_db_migrate",
      "image": "${aws_ecr_repository.my_app_repo.repository_url}",
      "command": ["bundle", "exec", "rake", "db:migrate"],
      "essential": true,
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.my_app.name}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "rails"
        }
      },
      "environment": [
        {
          "name": "RAILS_LOG_TO_STDOUT",
          "value": "true"
        },
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
