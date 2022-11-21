resource "google_storage_bucket" "gcs_bucket" {
  name = "test-bucket-randon-144124"
}

resource "google_storage_bucket" "gcs_buckte_2" {
  name = "novo-teste-bucket-ms"
  location = var.region
}