provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_iam_group_membership" "terraform_team" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.user.name
  ]

  group = aws_iam_group.developers.name


}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"


}

resource "aws_iam_user_policy" "user_ro" {
  name = "test"
  user = aws_iam_user.user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_user" "user" {
  name = var.name

}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_login_profile" "user" {
  user    = aws_iam_user.user.name
  pgp_key = "keybase:tds"


}

resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = aws_iam_user.user.name
  policy_arn = var.policy_arns

}

resource "aws_iam_role" "developer_role" {
  name = "developer_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "terraform_team"
  }
}