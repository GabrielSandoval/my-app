resource "aws_ecs_task_definition" "my_app_web" {
  family                = "my_app_web" # Name your task
  container_definitions = templatefile("./task_definitions/web.json",
    {
      name              = "my_app_web"
      image             = "${aws_ecr_repository.my_app_repo.repository_url}"
      awslogs_group     = "${aws_cloudwatch_log_group.my_app.name}"
      awslogs_prefix    = "web"
      environment       = "development"
      host              = "${aws_alb.my_app_load_balancer.dns_name}"
      database_host     = "${aws_db_instance.rds.address}"
      database_name     = "${aws_db_instance.rds.db_name}"
      database_username = "${aws_db_instance.rds.username}"
      database_password = "${aws_db_instance.rds.password}"
    }
  )
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 2048        # Specify the memory the container requires
  cpu                      = 1024        # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
}

resource "aws_ecs_task_definition" "my_app_db_create" {
  family                = "my_app_db_create" # Name your task
  container_definitions = templatefile("./task_definitions/db_create.json",
    {
      name              = "my_app_db_create"
      image             = "${aws_ecr_repository.my_app_repo.repository_url}"
      awslogs_group     = "${aws_cloudwatch_log_group.my_app.name}"
      awslogs_prefix    = "db_create"
      environment       = "development"
      host              = "${aws_alb.my_app_load_balancer.dns_name}"
      database_host     = "${aws_db_instance.rds.address}"
      database_name     = "${aws_db_instance.rds.db_name}"
      database_username = "${aws_db_instance.rds.username}"
      database_password = "${aws_db_instance.rds.password}"
    }
  )
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 2048        # Specify the memory the container requires
  cpu                      = 1024        # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
}

resource "aws_ecs_task_definition" "my_app_db_migrate" {
  family                = "my_app_db_migrate" # Name your task
  container_definitions = templatefile("./task_definitions/db_migrate.json",
    {
      name              = "my_app_db_migrate"
      image             = "${aws_ecr_repository.my_app_repo.repository_url}"
      awslogs_group     = "${aws_cloudwatch_log_group.my_app.name}"
      awslogs_prefix    = "db_migrate"
      environment       = "development"
      database_host     = "${aws_db_instance.rds.address}"
      database_name     = "${aws_db_instance.rds.db_name}"
      database_username = "${aws_db_instance.rds.username}"
      database_password = "${aws_db_instance.rds.password}"
    }
  )
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 2048        # Specify the memory the container requires
  cpu                      = 1024        # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
}
