resource "aws_s3_bucket" "kudo_o_matic_production" {
  bucket = "kudo-o-matic-production"
}

resource "aws_s3_bucket" "kudo_o_matic_development" {
  bucket = "kudo-o-matic-development"
}

resource "aws_s3_bucket" "kudo_o_matic_staging" {
  bucket = "kudo-o-matic-staging"
}

resource "aws_iam_user" "kudo_user" {
  name = "kudo-user"
}

resource "aws_iam_policy" "kudo_policy" {
  name        = "kudo-s3-access-policy"
  description = "Policy to allow full access to kudo S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListAllMyBuckets"
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          aws_s3_bucket.kudo_o_matic_development.arn,
          "${aws_s3_bucket.kudo_o_matic_development.arn}/*",
          aws_s3_bucket.kudo_o_matic_staging.arn,
          "${aws_s3_bucket.kudo_o_matic_staging.arn}/*",
          aws_s3_bucket.kudo_o_matic_production.arn,
          "${aws_s3_bucket.kudo_o_matic_production.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "kudo_user_policy_attachment" {
  user       = aws_iam_user.kudo_user.name
  policy_arn = aws_iam_policy.kudo_policy.arn
}
