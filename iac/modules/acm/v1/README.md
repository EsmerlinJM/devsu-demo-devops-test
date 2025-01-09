# Módulo Terraform para el Certificado ACM de Amazon con Validación DNS en Route 53

Este módulo crea un certificado SSL utilizando Amazon ACM (AWS Certificate Manager) para un dominio especificado y configura la validación de DNS utilizando Route 53.

## Prerrequisitos

- Terraform v1.10.3
- Proveedor AWS versión 5.82.2

## Variables

| Nombre              | Descripción                                                       | Tipo     | Predeterminado       |
| ------------------- | ----------------------------------------------------------------- | -------- | -------------------- |
| `domain_name`        | Nombre del dominio para el certificado ACM                        | `string` | `esmerlinmieses.com`  |
| `environment`        | Variable de entorno utilizada como prefijo para las etiquetas     | `string` | `dev`                |

## Salidas

| Nombre                 | Descripción                                        |
| ---------------------- | -------------------------------------------------- |
| `cert_acm`             | ARN del certificado ACM creado                    |

## Recursos

### Zona de Route 53 (`aws_route53_zone`)

Este recurso selecciona la zona pública de Route 53 para el dominio especificado.

### Certificado ACM (`aws_acm_certificate`)

Este recurso crea un certificado ACM para el dominio especificado y configura la validación mediante DNS. Además, se configura un nombre alternativo para el sujeto (`subject_alternative_names`) para incluir todos los subdominios del dominio principal.

### Registro de Validación en Route 53 (`aws_route53_record`)

Este recurso crea registros DNS en la zona de Route 53 para validar el certificado ACM mediante el método de validación DNS. Se genera un registro CNAME para cada opción de validación de dominio proporcionada por el certificado ACM.

### Validación del Certificado ACM (`aws_acm_certificate_validation`)

Este recurso valida el certificado ACM utilizando los registros DNS creados en Route 53. El certificado se considera válido cuando los registros DNS se propagan correctamente.

## Ejemplo de Uso

```hcl
module "acm_route53" {
  source = "./modules/aws/acm-route53/v1"

  domain_name = "example.com"
  environment = "dev"
}
