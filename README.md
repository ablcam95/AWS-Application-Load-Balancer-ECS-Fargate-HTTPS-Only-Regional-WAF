
# 🚀 AWS Application Load Balancer + ECS Fargate + HTTPS Only + Regional WAF

Este repositorio contiene la configuración en **Terraform** para desplegar una arquitectura de microservicios contenerizados altamente segura, escalable y moderna en AWS utilizando **Amazon ECS Fargate**, protegida por un **Application Load Balancer (ALB)** con redirección automática a HTTPS y un **AWS WAFv2** adjunto.

---

## 🏗️ Arquitectura y Recursos Desplegados

El código provisiona los siguientes componentes clave en AWS:

1. **Amazon ECS Cluster (`max-lab-cluster`)**: El clúster lógico para administrar los contenedores.
2. **ECS Task Definition (`max-lab-app`)**: Configurada con el modo de red `awsvpc`, usando contenedores Fargate (CPU: `512`, Memoria: `1024`) ejecutando una imagen alojada en Amazon ECR (`app:latest`) escuchando en el puerto `8080`.
3. **ECS Service (`max-lab-svc`)**: Mantiene un recuento deseado (`desired_count = 2`) de tareas ejecutándose de forma concurrente para garantizar alta disponibilidad.
4. **Application Load Balancer (`max-lab-alb`)**: Balanceador de carga orientado a Internet que distribuye el tráfico hacia el Target Group en subredes públicas.
5. **Políticas de Redirección HTTP/HTTPS**:
   * **Puerto 443 (HTTPS)**: Cifra el tráfico utilizando una política de seguridad estricta (`ELBSecurityPolicy-TLS13-1-2-2021-06`) y un certificado SSL de AWS ACM, reenviando las peticiones al Target Group.
   * **Puerto 80 (HTTP)**: Configurado con una regla de redirección automática hacia HTTPS con un código de estado `HTTP_301` (Moved Permanently).
6. **Target Group (`max-lab-tg`)**: Configurado con tipo de destino por dirección IP (`ip`) y revisiones de salud (*health checks*) apuntando al endpoint `/health`.
7. **AWS WAFv2 Web ACL (`max-lab-acl`)**: Firewall perimetral regional asociado al ALB con el conjunto de reglas comunes gestionadas por AWS (`AWSManagedRulesCommonRuleSet`) para mitigar vulnerabilidades web comunes.

---

## 📋 Prerrequisitos

Antes de implementar esta infraestructura, verifica que cuentas con:

* [Terraform](https://www.developer.hashicorp.com/terraform/downloads) instalado (versión 1.0 o superior).
* Credenciales de [AWS CLI](https://aws.amazon.com/cli/) con permisos para administrar recursos de ECS, IAM, ELBv2, WAFv2 y ACM.
* Recursos previos existentes en tu cuenta (ej. VPC, Subnets y Security Groups con los IDs que correspondan a los definidos en el código).

---

## ⚙️ Configuración y Uso

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/ablcam95/AWS-Application-Load-Balancer-ECS-Fargate-HTTPS-Only-Regional-WAF.git
   cd AWS-Application-Load-Balancer-ECS-Fargate-HTTPS-Only-Regional-WAF


<img width="1192" height="519" alt="image" src="https://github.com/user-attachments/assets/45849e82-6702-43c4-9061-30d5f9872072" />
