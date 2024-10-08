resource "aws_security_group" "team3_sg" {
name = "${var.name}-sg"
description = "ssh-http-icmp-sql"
vpc_id = aws_vpc.eks_vpc.id
ingress = [
{
description = "ssh"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
prefix_list_ids = null
security_groups = null
self = null
},
{
description = "http"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
prefix_list_ids = null
security_groups = null
self = null
},
{
description = "icmp"
from_port = -1
to_port = -1
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
prefix_list_ids = null
security_groups = null
self = null
},
{
description = "mysql"
from_port = 3306
to_port = 3306
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
prefix_list_ids = null
security_groups = null
self = null
},
{
description = "https"
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
prefix_list_ids = null
security_groups = null
self = null
}
]
egress {
description = "all"
from_port = 0
to_port = 0
protocol = -1
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}
tags = {
Name = "${var.name}-sg"
}
}