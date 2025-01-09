# Módulo Personalizado de VPC para AWS EKS

Este módulo de Terraform crea una Virtual Private Cloud (VPC) personalizada diseñada para soportar un clúster de AWS Elastic Kubernetes Service (EKS). El módulo configura subredes públicas y privadas, una NAT Gateway (opcional) y las tablas de rutas necesarias para una conectividad óptima dentro de un entorno EKS.

## Prerrequisitos

- Terraform 1.10.3
- AWS Provider v5.82.2

## Variables del Módulo

| Nombre                            | Descripción                                                          | Tipo          | Predeterminado |
| ---------------------------------- | -------------------------------------------------------------------- | ------------- | -------------- |
| `nat_gateway`                      | Desplegar NAT Gateway.                                               | `bool`        | `false`        |
| `vpc_name`                         | Nombre de la VPC.                                                    | `string`      |                |
| `cidr_block`                       | El bloque CIDR IPv4 para la VPC.                                     | `string`      | `10.0.0.0/16`  |
| `enable_dns_support`               | Habilitar/deshabilitar el soporte DNS en la VPC.                     | `bool`        | `true`         |
| `enable_dns_hostnames`             | Habilitar/deshabilitar nombres de host DNS en la VPC.                 | `bool`        | `false`        |
| `default_tags`                     | Un mapa de etiquetas para agregar a todos los recursos.               | `map(string)` | `{}`           |
| `subnet_public_count`              | Número de subredes públicas.                                         | `number`      | `3`            |
| `subnet_public_additional_bits`    | Bits adicionales para extender el prefijo de las subredes públicas.   | `number`      | `4`            |
| `subnet_public_tags`               | Etiquetas para agregar a todas las subredes públicas.                 | `map(string)` | `{}`           |
| `subnet_private_count`             | Número de subredes privadas.                                         | `number`      | `3`            |
| `subnet_private_additional_bits`   | Bits adicionales para extender el prefijo de las subredes privadas.   | `number`      | `4`            |
| `subnet_private_tags`              | Etiquetas para agregar a todas las subredes privadas.                 | `map(string)` | `{}`           |

## Salidas

| Nombre                           | Descripción                                        |
| -------------------------------- | -------------------------------------------------- |
| `aws_vpc`                        | La VPC creada.                                     |
| `subnets_public`                 | Subredes públicas dentro de la VPC.                |
| `subnets_private`                | Subredes privadas dentro de la VPC.                |
| `aws_internet_gateway`           | La pasarela de internet para la VPC.              |
| `aws_route_table_public`         | El ID de la tabla de rutas públicas.              |
| `aws_route_table_private`        | El ID de la tabla de rutas privadas.              |
| `nat_gateway_ipv4_address`       | La dirección IPv4 de la NAT Gateway.              |

## Uso Ejemplo

```hcl
module "custom_vpc" {
  source = "./modules/aws/vpc/v1"

  nat_gateway              = true
  vpc_name                 = "demo-vpc"
  cidr_block               = "10.0.0.0/16"
  enable_dns_support       = true
  enable_dns_hostnames     = true
  default_tags             = {
                               Environment = "dev"
                             }
  subnet_public_count      = 3
  subnet_public_additional_bits = 4
  subnet_public_tags       = {
                               Tier = "public"
                             }
  subnet_private_count     = 3
  subnet_private_additional_bits = 4
  subnet_private_tags      = {
                               Tier = "private"
                             }
}
