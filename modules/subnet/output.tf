locals {
  subnet_ids_by_usage = {
    for usage in distinct([for s in aws_subnet.this : s.tags["Usage"]]) :
    usage => {
      for k, s in aws_subnet.this :
      var.subnets[k].az_suffix => s.id if s.tags["Usage"] == usage
    }
  }
}

output "ids_by_usage" {
  value = local.subnet_ids_by_usage
}
