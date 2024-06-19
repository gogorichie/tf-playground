// Use environment variables if you like

variable "prefix" {
  default = "duck"
  type    = string
}

# variable "service_principal" {
#   type = object({
#     client_id     = string
#     client_secret = string
#   })
#   sensitive = true
# }