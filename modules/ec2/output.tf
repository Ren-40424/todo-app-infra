output "instance_ids" {
  value = { for k, instance in aws_instance.this : k => instance.id }
}

output "sg_id" {
  value = module.sg.id
}
