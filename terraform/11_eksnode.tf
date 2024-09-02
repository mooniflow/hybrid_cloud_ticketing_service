resource "aws_eks_node_group" "eks_node" {
cluster_name = aws_eks_cluster.eks_cluster.name
node_group_name = "node-group2"
node_role_arn = aws_iam_role.eks_noderole.arn
subnet_ids = concat(
[aws_subnet.eks_sub_worker1.id],
[aws_subnet.eks_sub_worker2.id]
)
capacity_type = "ON_DEMAND"
disk_size = 20
instance_types = ["t3.medium"]
scaling_config {
desired_size = 2
max_size = 5
min_size = 2
}
update_config {
max_unavailable = 1
}
depends_on = [
aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy,
aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_Policy,
aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly,
]
}
resource "aws_iam_role" "eks_noderole" {
name = "eks-noderole"




assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [
{
Action = "sts:AssumeRole"
Effect = "Allow"
Principal = {
Service = "ec2.amazonaws.com"
}
}
]
})


inline_policy {
    name   = "sqs-s3-policy"
    policy = jsonencode({
	    "Version": "2012-10-17",
	    "Statement": [
		    {
		        "Sid": "VisualEditor0",
		        "Effect": "Allow",
		        "Action": "sqs:ListQueues",
		        "Resource": "*"
		    },
		    {
		        "Sid": "VisualEditor1",
		        "Effect": "Allow",
		        "Action": "sqs:*",
		        "Resource": "arn:aws:sqs:*:447079561480:*"
		    },
			{
          		"Sid": "VisualEditor2",
          		"Effect": "Allow",
          		"Action": "s3:*",
          		"Resource": ["arn:aws:s3:::*/*", "arn:aws:s3:::*"]

        	}
	    ]
    })    
}
}



resource "aws_iam_role_policy_attachment" "eks_AmazonEKSWorkerNodePolicy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
role = aws_iam_role.eks_noderole.name
}
resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
role = aws_iam_role.eks_noderole.name
}
resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly"{
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
role = aws_iam_role.eks_noderole.name
}
resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryPowerUser"{
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
role = aws_iam_role.eks_noderole.name
}
resource "aws_iam_role_policy_attachment" "eks_AmazonSSMManagedInstanceCore"{
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
role = aws_iam_role.eks_noderole.name
}
resource "aws_iam_role_policy_attachment" "eks_CloudWatchAgentServerPolicy"{
policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
role = aws_iam_role.eks_noderole.name
}
