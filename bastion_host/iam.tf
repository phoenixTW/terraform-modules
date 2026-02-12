data "aws_iam_policy_document" "assume_bastion_role_policy" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_role" {
  name               = "${local.name_prefix}-bastion-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_bastion_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.name_prefix}-bastion-iam-instance-profile"
  role = aws_iam_role.bastion_role.name
}

data "aws_iam_policy_document" "cloudwatch_logs_policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name   = "${local.name_prefix}-bastion-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
