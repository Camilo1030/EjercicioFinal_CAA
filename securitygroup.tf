# Creación del security group
resource "aws_security_group" "example_security_group" {
  name        = "example-security-group"
  description = "Security group example for SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc_terraform.id # Cambia al ID de tu VPC

  # Regla de entrada permitiendo el tráfico SSH desde cualquier lugar
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de entrada permitiendo el tráfico HTTP desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida permitiendo todo el tráfico
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
