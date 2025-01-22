#______________________________________________
#
# Intersight Provider Settings
#______________________________________________

variable "intersight_api_key_id" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
  validation {
    condition     = length(regexall("^[\\da-f]{24}/[\\da-f]{24}/[\\da-f]{24}$", var.intersight_api_key_id)) > 0
    error_message = "Interisght API Key Should match the following: ```^[\\da-f]{24}/[\\da-f]{24}/[\\da-f]{24}$```"
  }
}

variable "intersight_secret_key" {
  default     = "blah.txt"
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}

variable "model" {
  default     = "./policies/p.yaml"
  description = "YAML to HCL Data - model."
  type        = any
}

#variable "orgs" {
#  description = "Intersight Organizations Moid Data."
#  type        = any
#}

