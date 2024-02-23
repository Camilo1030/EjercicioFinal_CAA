# Creación del Cluster de ECS
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
}

# Creación de las tareas de ECS
resource "aws_ecs_task_definition" "task_a" {
  family                   = "task-a"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn = "arn:aws:iam::533267260042:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name  = "my-container-a",
      image = "533267260042.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo:nginxlatest", # Cambia a la imagen de tu contenedor
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "task_b" {
  family                   = "task-b"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn = "arn:aws:iam::533267260042:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name  = "my-container-b",
      image = "533267260042.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo:nginxlatest", # Cambia a la imagen de tu contenedor
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Creación de los servicios de ECS
resource "aws_ecs_service" "service_a" {
  name            = "service-a"
  cluster         = aws_ecs_cluster.my_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.task_a.arn
  desired_count   = 2
  launch_type     = "FARGATE"
    
  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id] # Cambia al ID de tu subnet
    assign_public_ip = true
    security_groups  = [aws_security_group.example_security_group.id] # Cambia al ID de tu security group
  }
 load_balancer {
    target_group_arn = aws_lb_target_group.target.id
    container_name   = "my-container-a"
    container_port   = 80  
  }
  depends_on = [aws_ecs_cluster.my_ecs_cluster, aws_ecs_task_definition.task_a,aws_lb_target_group.target]
}

resource "aws_ecs_service" "service_b" {
  name            = "service-b"
  cluster         = aws_ecs_cluster.my_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.task_b.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.public_subnet_2.id] # Cambia al ID de tu subnet
    assign_public_ip = true
    security_groups  = [aws_security_group.example_security_group.id] # Cambia al ID de tu security group
    
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target.id
    container_name   = "my-container-b"
    container_port   = 80  
  }
  depends_on = [aws_ecs_cluster.my_ecs_cluster, aws_ecs_task_definition.task_b,aws_lb_target_group.target]
}

# Creación del Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] # Cambia a los IDs de tus subnets

  enable_deletion_protection = false

  security_groups = [aws_security_group.example_security_group.id] # Cambia al ID de tu security group
}

# Creación del listener del ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}

# Creación del target group del ALB
resource "aws_lb_target_group" "target" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.my_vpc_terraform.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Recurso para asociar el listener del ALB a los servicios de ECS
resource "aws_lb_listener_rule" "example_listener_rule" {
  listener_arn = aws_lb_listener.listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }

  condition {
    path_pattern {
      values = ["/*"] # Cambia el patrón de ruta según tus necesidades
    }
}
}
