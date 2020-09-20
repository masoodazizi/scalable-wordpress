# resource "aws_iam_instance_profile" "instance_profile" {
#   name = "wp-instance-profile"
#   path = "/"
#   role = aws_iam_role.instance_role.name
# }
#
# resource "aws_iam_role" "instance_role" {
#   name = "wp-instance-role"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
#
# }
#
# resource "aws_iam_role_policy" "instance_policy" {
#   name = "wp-instance-policy"
#   role = aws_iam_role.instance_role.id
#
#   policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": [
#           "ec2:Describe*"
#         ],
#         "Effect": "Allow",
#         "Resource": "*"
#       }
#     ]
#   }
#   EOF
# }

