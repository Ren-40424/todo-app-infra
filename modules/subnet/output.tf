output "ids_by_usage" {
  value = {
    for k, subnet in aws_subnet.this :
    subnet.tags["Usage"] => subnet.id...
  }
}
