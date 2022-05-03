# can define machine_type to "dev", "uat"
variable "environment" {default = "dev"}

variable "prefix" { default = "tfsnitin" }
variable "name" { default = "resources" }
variable "location" { default = "East US 2" }

variable "vm_size_dev" {default = "Standard_DS1_v2"}
variable "vm_size_uat" {default = "Standard_DS2_v2"}