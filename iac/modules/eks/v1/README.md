# Módulo de Terraform para Amazon EKS

Este módulo crea un clúster de Amazon EKS (Elastic Kubernetes Service) con grupos de nodos administrados en AWS.

## Prerrequisitos

- Terraform v1.10.3
- AWS Provider v5.82.2
- Kubernetes Provider v2.35.1

## Entradas

| Nombre                    | Descripción                                                                                             | Tipo           | Predeterminado |
| ------------------------- | ------------------------------------------------------------------------------------------------------- | -------------- | -------------- |
| `region`                  | Región de AWS                                                                                             | `string`       |                |
| `vpc_id`                  | ID de la VPC                                                                                                | `string`       |                |
| `cluster_name`            | Nombre del clúster de EKS                                                                                  | `string`       |                |
| `public_subnets`          | IDs de las subredes públicas para el clúster de EKS                                                        | `list(string)` |                |
| `private_subnets`         | IDs de las subredes privadas para el clúster de EKS                                                        | `list(string)` |                |
| `default_ami_type`        | El tipo de AMI que se utilizará para el grupo de nodos. Valores válidos: `AL2_x86_64`, `AL2_x86_64_GPU`    | `string`       | `AL2_x86_64`   |
| `default_capacity_type`   | El tipo de capacidad para el grupo de nodos. Valores válidos: `ON_DEMAND`, `SPOT`                         | `string`       | `SPOT`         |
| `managed_node_groups`     | Configuración para los grupos de nodos administrados. Cada grupo especifica nombre, tipos de instancias y ajustes de escalabilidad | `map(object)`  | `{}`           |
| `cluster_addons`          | Lista de cadenas que especifican los complementos del clúster                                             |

## Salidas

| Nombre                            | Descripción                                                  |
| ---------------------------------- | ------------------------------------------------------------ |
| `cluster_id`                       | El ID del clúster de EKS creado                               |
| `cluster_endpoint`                 | El punto final para tu servidor API de Kubernetes            |
| `cluster_security_group_id`        | El ID del grupo de seguridad del clúster                     |
| `node_group_role_arn`              | El ARN del rol de IAM utilizado por los grupos de nodos       |
| `cluster_admins_role`              | El ARN del rol para que los administradores del clúster asuman el acceso |
| `cluster_certificate_authority_data` | Los datos del certificado base64 requeridos para comunicarse con el clúster |
| `cluster_auth_token`               | El token requerido para autenticarte con el clúster          |
| `oidc_provider_arn`                | El ARN OIDC del clúster                                      |
| `oidc_provider_id`                 | El ID OIDC del clúster                                       |


## Uso

Ejemplo para crear un clúster de EKS con un grupo de nodos administrado:

```hcl
module "eks" {
  source = "./modules/aws/eks/v2"

  region       = "eu-west-1"
  cluster_name = "my-eks-cluster"
  subnets      = ["subnet-xxxxxx", "subnet-yyyyyy", "subnet-zzzzzz"]
  vpc_id       = "vpc-xxxxxxx"

  managed_node_groups = {
    example_group = {
      name           = "example-node-group"
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.large"]
    }
  }

  tags = {
    Environment = "development"
    Project     = "Kubernetes"
  }
}
