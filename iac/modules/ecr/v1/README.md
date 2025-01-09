# Modulo de Terraform para Amazon ECR

Este módulo crea un repositorio Amazon ECR (Elastic Container Registry) con una política de ciclo de vida para gestionar imágenes y configuraciones relacionadas.

## Prerequisitos

- Terraform v1.10.3
- AWS provider versión 5.82.2

## Variables

| Nombre                     | Descripción                                                     | Tipo     | Predeterminado |
| -------------------------- | --------------------------------------------------------------- | -------- | -------------- |
| `region`                   | Región de AWS                                                    | `string` | `us-east-1`    |
| `ecr_repository_name`       | Nombre del repositorio ECR                                       | `string` |                |
| `ecr_scan_on_push`          | Habilitar escaneo de imágenes al hacer push (valor booleano)     | `bool`   | `true`         |
| `environment`               | Variable de entorno utilizada como prefijo                      | `string` | `dev`          |

## Salidas

| Nombre                        | Descripción                                                       |
| ----------------------------- | --------------------------------------------------------------- |
| `repository_name`             | El nombre del repositorio                                         |
| `public_repository_url`       | La URL del repositorio                                           |

## Ejemplo de Uso

```hcl
module "ecr" {
  source = "./modules/aws/ecr/v1"

  region              = "us-east-1"
  ecr_repository_name = "my-app-repo"
  ecr_scan_on_push    = true
  environment         = "dev"
}
