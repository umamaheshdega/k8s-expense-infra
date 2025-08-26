variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "domain_name" {
    default = "maheshdevops.store"
}

variable "zone_id" {
    default = "Z000063939MD4K8HB2GI8"
}