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

## Recursos

### Repositorio ECR (`aws_ecr_repository`)

Este recurso crea un repositorio de ECR con las siguientes configuraciones:
- **image_tag_mutability:** Se establece en `"MUTABLE"`, lo que permite cambiar las etiquetas de las imágenes.
- **image_scanning_configuration:** Habilita el escaneo de imágenes al hacer push según el valor de la variable `ecr_scan_on_push`.

### Política de Ciclo de Vida de ECR (`aws_ecr_lifecycle_policy`)

Este recurso define una política de ciclo de vida para eliminar imágenes antiguas:
- **Regla:** Retener solo las últimas 10 imágenes.
- **Condición:** Se elimina cualquier imagen cuando el número de imágenes en el repositorio excede las 10.

## Ejemplo de Uso

```hcl
module "ecr" {
  source = "./modules/aws/ecr/v1"

  region              = "us-east-1"
  ecr_repository_name = "my-app-repo"
  ecr_scan_on_push    = true
  environment         = "dev"
}
