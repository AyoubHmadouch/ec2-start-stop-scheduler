# data:
data "aws_ssm_document" "start_ec2" {
  name = "AWS-StartEC2Instance"
}

data "aws_ssm_document" "stop_ec2" {
  name = "AWS-StopEC2Instance"
}

# resources:
resource "aws_ssm_maintenance_window" "self" {
  for_each          = { for s in var.schedules : s.name => s }
  name              = "${each.value.name}-maintenance-window"
  schedule          = each.value.schedule
  duration          = 2
  cutoff            = 1
  enabled           = true
  description       = each.value.description
  schedule_timezone = each.value.schedule_timezone
  tags = {
    Name = "${each.value.name}-maintenance-window"
  }
}

resource "aws_ssm_maintenance_window_target" "self" {
  for_each      = { for s in var.schedules : s.name => s }
  window_id     = aws_ssm_maintenance_window.self[each.key].id
  name          = "${each.value.name}-target"
  resource_type = "INSTANCE"
  targets {
    key    = "InstanceIds"
    values = each.value.target_instance_ids
  }
}

resource "aws_ssm_maintenance_window_task" "self" {
  for_each         = { for s in var.schedules : s.name => s }
  window_id        = aws_ssm_maintenance_window.self[each.key].id
  task_type        = "AUTOMATION"
  task_arn         = each.value.action == "start" ? data.aws_ssm_document.start_ec2.name : data.aws_ssm_document.stop_ec2.name
  service_role_arn = aws_iam_role.ssm.arn
  priority         = 1
  max_concurrency  = "1"
  max_errors       = "1"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.self[each.key].id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"
      parameter {
        name   = "InstanceId"
        values = ["{{RESOURCE_ID}}"]
      }
    }
  }
}
