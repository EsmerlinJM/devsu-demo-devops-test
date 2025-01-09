# Módulo Terraform para el Certificado ACM de Amazon con Validación DNS en Route 53

Este módulo crea un certificado SSL utilizando Amazon ACM (AWS Certificate Manager) para un dominio especificado y configura la validación de DNS utilizando Route 53.

## Prerrequisitos

- Terraform v1.10.3
- AWS provider versión 5.82.2

## Variables

| Nombre              | Descripción                                                       | Tipo     | Predeterminado       |
| ------------------- | ----------------------------------------------------------------- | -------- | -------------------- |
| `domain_name`        | Nombre del dominio para el certificado ACM                        | `string` | `esmerlinmieses.com`  |
| `environment`        | Variable de entorno utilizada como prefijo para las etiquetas     | `string` | `dev`                |

## Salidas

| Nombre                 | Descripción                                        |
| ---------------------- | -------------------------------------------------- |
| `cert_acm`             | ARN del certificado ACM creado                    |

## Ejemplo de Uso

```hcl
module "acm_route53" {
  source = "./modules/aws/acm-route53/v1"

  domain_name = "example.com"
  environment = "dev"
}
