data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

resource "aws_eks_cluster" "main" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids             = concat(var.private_subnets, var.public_subnets)
    security_group_ids     = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access = true

  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_encryption.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

resource "aws_kms_key" "eks_encryption" {
  description         = "KMS key for EKS cluster encryption"
  policy              = data.aws_iam_policy_document.kms_key_policy.json
  enable_key_rotation = true
}

# alias
resource "aws_kms_alias" "eks_encryption" {
  # name          = "alias/eks/${var.cluster_name}"
  target_key_id = aws_kms_key.eks_encryption.id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid = "Key Administrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:TagResource"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        data.aws_caller_identity.current.arn
      ]
    }
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    resources = ["*"]
  }
}


resource "aws_iam_policy" "cluster_encryption" {
  name        = "${var.cluster_name}-encryption-policy"
  description = "IAM policy for EKS cluster encryption"
  policy      = data.aws_iam_policy_document.cluster_encryption.json
}

data "aws_iam_policy_document" "cluster_encryption" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.eks_encryption.arn]
  }
}

# Granting the EKS Cluster role the ability to use the KMS key
resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  policy_arn = aws_iam_policy.cluster_encryption.arn
  role       = aws_iam_role.eks_cluster_role.name
}


# Manage node groups
resource "aws_eks_node_group" "main" {
  for_each = var.managed_node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_types       = each.value.instance_types
  ami_type             = var.default_ami_type
  capacity_type        = var.default_capacity_type
  force_update_version = true
}

# Launch template
resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.cluster_name}-eks-node-group-lt"
  description = "Launch template for ${var.cluster_name} EKS node group"

  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]

  # key_name = "terraform"

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "${var.cluster_name}-eks-node-group"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda" 

    ebs {
      volume_size           = 20 
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-eks-node-group"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}


variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = aws_iam_openid_connect_provider.oidc_provider.arn 
}

locals {
    aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}


output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
   value = local.aws_iam_oidc_connect_provider_extract_from_arn
}


# Cluster Security group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane communication with worker nodes"
  vpc_id      = var.vpc_id

  lifecycle {
    prevent_destroy = false
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-eks-cluster-sg"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow inbound traffic from the worker nodes on the Kubernetes API endpoint port"
}

resource "aws_security_group_rule" "eks_cluster_egress_kublet" {
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow control plane to node egress for kubelet"
}

resource "aws_security_group_rule" "eks_cluster_egress_nginx" {
  type                     = "egress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow control plane to node egress for nginx"
}

# Node Security group
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-eks-nodes-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name                                        = "${var.cluster_name}-eks-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "worker_node_ingress_nginx" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to node ingress for nginx"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_coredns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes_sg.id
  self              = true
  description       = "Allow workers nodes to communicate with each other for coredns TCP"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_coredns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.eks_nodes_sg.id
  self              = true
  description       = "Allow workers nodes to communicate with each other for coredns UDP"
}

resource "aws_security_group_rule" "worker_node_ingress_kublet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to node ingress for kubelet"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_ephemeral" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow workers nodes to communicate with each other on ephemeral ports"
}

resource "aws_security_group_rule" "eks_nodes_ingress_alb" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow access from control plane to webhook port of AWS load balancer controller"
}

resource "aws_security_group_rule" "worker_node_egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow outbound internet access"
}

# Addons
data "aws_eks_addon_version" "main" {
  for_each = toset(var.cluster_addons)

  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.main.version
}

resource "aws_eks_addon" "main" {
  for_each = toset(var.cluster_addons)

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = data.aws_eks_addon_version.main[each.key].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.main
  ]
}