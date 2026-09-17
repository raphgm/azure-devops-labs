variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "Southeast Asia"
}

variable "environment" {
  description = "Environment name, used as a naming/tagging suffix (staging, production)."
  type        = string
  default     = "staging"
}

variable "vm_count" {
  description = "Number of application VMs behind the load balancer."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM SKU. See the article for the family cheat sheet (Dsv5/Fsv2/Esv5/Lsv3)."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_ssh_public_key_path" {
  description = "Path to the SSH public key used for VM admin access."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
