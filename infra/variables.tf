variable "subscription_id" {
  description = "Azure subscription"
  type        = string
  default     = "20c17ce1-c880-4374-ab18-0c3a72158cf7"
}

variable "appname" {
  description = "Product name"
  type        = string
  default     = "gwa"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Canada Central"
}

variable "exampletag" {
  description = "Example use of a tag"
  type        = string
  default     = "exampletag"
}

variable "env_name" {
  description = "Working environment"
  type        = string
  default     = "dev"
}

variable "website_hostname" {
  description = "Default website hostname"
  type        = string
  default     = "gwa-mccrackenyyc.nexxai.dev"
}