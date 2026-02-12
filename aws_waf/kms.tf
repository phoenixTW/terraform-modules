data "aws_iam_policy_document" "waf_cloudwatch_log_group_kms_key_policy" {
  version = "2012-10-17"
  statement {
    sid    = "WAFToUseKMS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current_region.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_kms_key" "kms_key_waf_cloudwatch_log_group" {
  enable_key_rotation = true
  description         = "KMS key for aws_cloudwatch log group"
  policy              = data.aws_iam_policy_document.waf_cloudwatch_log_group_kms_key_policy.json
}
