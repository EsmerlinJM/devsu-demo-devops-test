# Terraform EKS Cluster


Este repositorio contiene configuraciones de Terraform para desplegar un clúster de Amazon EKS (Elastic Kubernetes Service), AWS ACM (Certificate Manager) para aprovisionar, administrar y desplegar certificados SSL/TLS, AWS ECR para el almacenamiento administrado de las imagenes de contenedores y la infraestructura de VPC (Virtual Private Cloud) asociada en AWS. Utiliza principios de diseño modular para separar las configuraciones de VPC y EKS, brindando mayor claridad y reutilización.

## Recursos creados

El código de Terraform configura los siguientes recursos de AWS:

- **VPC:**
  - VPC con un bloque CIDR especificado.
  - Subredes públicas y privadas distribuidas en varias zonas de disponibilidad.
  - Internet Gateway para subredes públicas.
  - Tablas de enrutamiento y asociaciones para las subredes.
  - NAT Gateway para subredes privadas.
- **EKS Cluster:**
  - Clúster de EKS con una versión específica de Kubernetes.
  - Grupos de nodos gestionados para ejecutar cargas de trabajo de Kubernetes.
  - Grupos de seguridad para el plano de control y los nodos de trabajo.
  - Clave KMS para la encriptación de secretos del clúster EKS.
  - Roles e IAM Policies necesarios para la operación de EKS.
  - Un rol de administradores de EKS que otros usuarios pueden asumir para acceder al EKS.
  - Despliegue de addons como AWS Load Balancer Controller para administrar Elastic Load Balancers (ELB) en un clúster de Kubernetes y External DNS para sincronizar los Servicios expuestos de Kubernetes y los Ingress con los proveedores de DNS como Route 53, automatizando la gestión de registros DNS.
- **ECR:**
 - Facilitar el almacenamiento, intercambio y despliegue de imágenes de contenedores.
- **ACM:**
 - Facilitar la creación, administración y despliegue de certificados SSL/TLS para    proteger aplicaciones en AWS.

## Prerequisitos

- Cuenta de AWS y AWS CLI configurada.
- Terraform 1.10.3.
- Un bucket de S3 y una tabla de DynamoDB para la gestión del estado de Terraform (ver archivo terraform.tf).

## Uso

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/EsmerlinJM/devsu-demo-devops-test.git
   cd iac
   ```

2. **Inicializa Terraform:**

   ```bash
   terraform init
   ```

3. **Crear el archivo `terraform.tfvars` (Opcional)**

   Crear un archivo `terraform.tfvars` Para sobrescribir los valores predeterminados de las variables, crea un archivo terraform.tfvars en el directorio raíz del proyecto con el siguiente contenido como ejemplo:

   ```hcl
   region                     = "us-east-1"
   cluster_name               = "my-demo-cluster"
   aws_account_number         = "123456789"
   ```

4. **Configurar el Backend (Opcional)**

   Puedes configurar un backend remoto para administrar el estado de Terraform utilizando una tabla de DynamoDB y un bucket de S3. Esto asegura que el estado sea compartido y bloqueado adecuadamente para evitar conflictos en entornos colaborativos.

   ```bash
    aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

    aws s3api create-bucket --bucket my-terraform-state-bucket --region us-east-1

   backend "s3" {
    bucket         = "s3-bucket-name"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "us-east-1"
    encrypt        = true
   }
   ```

   También puedes simplemente eliminar el bloque de backend para mantener la gestión del estado de forma local.

5. **Planificar el Despliegue**

   Revisa las acciones que Terraform realizará.

   ```bash
    terraform plan
   ```

6. **Aplicar la Configuración**

   Despliega la infraestructura.

   ```bash
   terraform apply
   ```

   Confirma la acción escribiendo `yes` cuando se te solicite.

## Infrastructure Details

- **VPC (`module "vpc"`):** Configura una VPC llamada `demo-cluster-vpc` con un bloque CIDR especificado, y establece subredes públicas y privadas en tres zonas de disponibilidad. Se habilita un NAT Gateway para acceso a internet desde las subredes privadas.

- **EKS Cluster (`module "eks"`):** Implementa un clúster de EKS dentro de la VPC creada, utilizando las subredes privadas para los grupos de nodos administrados. Los grupos de nodos se configuran con tipos de instancia específicos y parámetros de escalado.

- **ECR Repository (`module "ecr"`):** Implementa configuraciones de Terraform para crear y gestionar repositorios ECR..

- **ECR Repository (`module "acm"`):** Implementa el nombre de dominio proporcionado para solicitar un certificado SSL de ACM. El certificado estará disponible para su uso en otros servicios de AWS como ELB (Elastic Load Balancer) por ejemplo.

- **Variables (`variables.tf`):** Define las variables de entrada para las configuraciones de Terraform, incluyendo la región de AWS, el nombre del clúster y configuraciones para el backend de S3.

- **Terraform Backend (`main.tf`):** Configura el backend de Terraform para usar un bucket de S3 para el almacenamiento del estado y una tabla de DynamoDB para el bloqueo del estado.

## Notas

- EAsegúrate de que el bucket de S3 y la tabla de DynamoDB especificados en `terraform.tf `existan antes de inicializar Terraform.
- Modifica el archivo `variables.tf` según tus necesidades o utiliza un archivo `terraform.tfvars` para configuraciones personalizadas.
- Revisa los costos de AWS asociados con los recursos creados por estas configuraciones.

## Destruir el entorno

```bash
terraform destroy
```

Al ejecutar el comando, Terraform te pedirá confirmación antes de proceder, y deberás escribir `yes` para confirmar la destrucción de los recursos.