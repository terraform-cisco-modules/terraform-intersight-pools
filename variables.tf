/*_____________________________________________________________________________________________________________________

Model Data from Top Level Module
_______________________________________________________________________________________________________________________
*/
variable "global_settings" {
  description = "YAML to HCL Data - global_settings."
  type        = any
}

variable "model" {
  description = "YAML to HCL Data - model."
  type        = any
}

variable "orgs" {
  description = "Intersight Organizations Moid Data."
  type        = any
}
