variable "defaults" {
  description = "Map of Defaults for Pools."
  type        = any
}

variable "organization" {
  default     = "default"
  description = "Name of the default intersight Organization."
  type        = string
}

variable "orgs" {
  description = "Input orgs List."
  type        = any
}

variable "pools" {
  description = "Pools - YAML to HCL Data."
  type        = any
}

variable "tags" {
  default     = []
  description = "List of Key/Value Pairs to Assign as Attributes to the Policy."
  type        = list(map(string))
}