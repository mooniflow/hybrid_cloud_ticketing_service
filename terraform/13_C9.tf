resource "aws_iam_role" "cloud9_role" {
  name = "eksworkspace-admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "cloud9_attachment" {
  role       = aws_iam_role.cloud9_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "cloud9-instance-profile2"
  role = aws_iam_role.cloud9_role.name
}
######Cloud9 instance에 부여할 role 생성########







resource "aws_cloud9_environment_ec2" "cloud9" {
  name           = "cloud9-environment2"
  instance_type  = "t3.medium"  # 사용할 EC2 인스턴스 타입 설정
  subnet_id      = aws_subnet.eks_sub_controlplane1.id  # 사용할 서브넷 ID 설정
  image_id      = "amazonlinux-2-x86_64"
  automatic_stop_time_minutes = 30  # 환경 자동 정지 시간 설정
  owner_arn      = "arn:aws:iam::447079561480:user/reca4_5_2"  # 소유자의 IAM 사용자 ARN 설정

}
