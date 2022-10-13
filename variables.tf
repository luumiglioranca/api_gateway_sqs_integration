variable "region" {
  type    = string
  default = ""
  description = "Região"
}
variable "account_id" {
  type    = string
  default = ""
  description = "ID da conta"
}
variable "vpc_id" {
  type    = string
  default = ""
  description = "ID da VPC"
}
variable "subnet_priv_1a" {
  type    = string
  default = ""
  description = "Subnet Privada 1A"
}
variable "subnet_priv_1b" {
  type    = string
  default = ""
  description = "Subnet Privada 1B"
}
variable "domain_name" {
  type    = string
  default = ""
  description = "Nome do Domínio - SSL"
}
variable task_role_arn_publisher {
  type        = string
  default     = ""
  description = "Publisher Service ARN"
}
variable task_role_arn_consumer {
  type        = string
  default     = ""
  description = "Consumer Service ARN"
}
variable queue_name {
  type        = string
  default     = ""
  description = "Queue Name"
}
variable api_domain_name {
  type        = string
  default     = ""
  description = "Domínio da nossa API"
}
variable ssl {
  type        = string
  default     = ""
  description = "Certificado de domínio da conta vigente"
}
variable endpoint_configuration {
  type        = string
  default     = ""
  description = "valor do endpoint configurado no custom domain"
}