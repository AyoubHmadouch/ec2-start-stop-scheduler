variable "schedules" {
  description = "(Required) List of schedules for the SSM Maintenance Window"
  type = list(object({
    name                = string
    action              = string
    schedule            = string
    schedule_timezone   = optional(string, "UTC")
    target_instance_ids = list(string)
    description         = optional(string, "")
  }))
  validation {
    condition     = alltrue([for s in var.schedules : s.action == "start" || s.action == "stop"])
    error_message = "Each schedule's action must be either \"start\" or \"stop\"."
  }
}
