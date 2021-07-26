terraform {
  required_version = ">= 0.15.5"

  required_providers {
    aws        = ">= 3.50.0"
    local      = ">= 2.1.0"
    random     = ">= 2.3.1"
    kubernetes = "~> 2.3.2"
  }
}