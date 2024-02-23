# Crear VPC
resource "aws_vpc" "my_vpc_terraform" {
  cidr_block = "10.0.0.0/24" # Cambia esto a tu rango de direcciones IP CIDR preferido
}

# Crear subredes públicas
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc_terraform.id
  cidr_block              = "10.0.0.0/25" # Cambia esto a tu rango de direcciones IP CIDR preferido
  availability_zone       = "us-east-1a" # Cambia esto a tu zona de disponibilidad preferida
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc_terraform.id
  cidr_block              = "10.0.0.128/25" # Cambia esto a tu rango de direcciones IP CIDR preferido
  availability_zone       = "us-east-1b" # Cambia esto a tu zona de disponibilidad preferida
}

# Crear Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc_terraform.id
}

# Crear tabla de rutas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc_terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Asociar subredes públicas a la tabla de rutas
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creación del Elastic Container Registry (ECR)
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"
}






