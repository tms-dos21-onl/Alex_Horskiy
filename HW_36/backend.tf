terraform {
  backend "gcs" {
    bucket = "dos-21"
    prefix = "terraform/state"
  }
}
