# data:
data "aws_iam_policy_document" "ec2_automation" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "iam:PassRole"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

# resources:
resource "aws_iam_role" "ssm" {
  name = "MaintenanceWindowRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy" "ssm_ec2_automation" {
  name   = "EC2AutomationPolicy"
  role   = aws_iam_role.ssm.name
  policy = data.aws_iam_policy_document.ec2_automation.json
}
