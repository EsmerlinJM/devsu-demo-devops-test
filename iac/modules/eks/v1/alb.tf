data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}

resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy = data.http.lbc_iam_policy.response_body
}

output "lbc_iam_policy_arn" {
  value = aws_iam_policy.lbc_iam_policy.arn 
}


resource "aws_iam_role" "lbc_iam_role" {
  name = "${var.cluster_name}-lbc-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "AWSLoadBalancerControllerIAMPolicy"
  }
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn 
  role       = aws_iam_role.lbc_iam_role.name
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value = aws_iam_role.lbc_iam_role.arn
}

 resource "helm_release" "alb-controller" {
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"
    depends_on = [
        aws_iam_role.lbc_iam_role,
    ]

    set {
        name  = "region"
        value = var.region
    }

    set {
        name  = "vpcId"
        value = var.vpc_id
    }

    set {
        name  = "image.repository"
        value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
    }

    set {
        name  = "serviceAccount.create"
        value = "true"
    }

    set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

    set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.lbc_iam_role.arn}"
  }

    set {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
    }

    set {
        name  = "clusterName"
        value = var.cluster_name
    }
 }

 resource "kubernetes_ingress_class_v1" "ingress_class_default" {
  depends_on = [helm_release.alb-controller]
  metadata {
    name = "my-aws-ingress-class"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }  
  spec {
    controller = "ingress.k8s.aws/alb"
  }
}

output "lbc_helm_metadata" {
  description = "Metadata of the deployed release."
  value = helm_release.alb-controller.metadata
}