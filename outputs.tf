output "maintenance_window_ids" {
  description = "List of maintenance window IDs"
  value       = [for s in var.schedules : aws_ssm_maintenance_window.self[s.name].id]
}
