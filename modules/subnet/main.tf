resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = "${var.aws_region}${each.value.az_suffix}"
  map_public_ip_on_launch = each.value.public ? true : false
  tags = {
    Name  = "${var.project_name}-subnet-${each.key}"
    AZ    = each.value.az_suffix
    Usage = each.value.usage
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "${var.project_name}-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for name, subnet in var.subnets :
    name => subnet if subnet.public
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}
