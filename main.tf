resource "google_storage_bucket" "gcs_bucket" {
  name = "test-bucket-randon-144124"
}

resource "google_storage_bucket" "gcs_buckte_2" {
  name = "novo-teste-bucket-ms"
  location = var.region
}

module "bigquery-dataset-gasolina" {
  source = "./modules/bigquery"
  dataset_id                  = "gasolina_brasil"
  dataset_name                = "gasoline_brasil"
  description                 = "Dataset de repositorio do historico de preços de Gasolina no Brasil a partir de 2004"
  project_id                  = var.project_id
  location                    = var.region
  delete_contents_on_destroy  = true
  deletion_protection         = false
  access = [
    {
      role = "OWNER"
      special_group = "projectOwners"
    },
    {
      role = "READER"
      special_group = "projectReaders"
    },
    {
      role = "WRITER"
      special_group = "projectWriters"
    }
  ]
  tables=[
    {
      table_id = "tb_historico_combustivel_brasil",
      description = "Tabela com as informaçoes de preco do combustivel ao longo dos anos"
      time_partitioning = {
        type                      = "DAY",
        field                     = "data",
        require_partition_filter  = false,
        expiration_ms             = null
      },
      range_partitioning = null,
      expiration_time = null,
      clustering  = ["produto", "regiao_sigla","estado_sigla"],
      labels = {
        name = "stack_data_pipeline"
        project = gasolina
      },
      deletion_protection = true
      schema = file("./bigquery/schema/gasolina_brasil/tb_historico_combustivel_brasil.json")
    }
  ]
}

module "bucket-raw" {
  source  = "./modules/gcs"

  name =  "msgcp-stack-data-pipeline-combustiveis-brasil-raw"
  project_id  = var.project_id
  location    = var.region
}

module "bucket-curated" {
  source = "./modules/gcs"

  name = "msgcp-stack-data-pipeline-combustiveis-brasil-cureted"
  project_id  = var.project_id
  location    = var.region
}

module "bucket-pyspark-tmp" {
  source = "./module/gcs"

  name  = "msgcp-stack-data-pipeline-stack-combustiveis-brasil-pyspark-tmp"
  project_id = var.project_id
  location  = var.region
  
}

module "bucket-pyspark-code" {
  source = "./modules/gcs"
  
  name = "msgcp-stack-data-pipeline-combustiveis-brasil-pyspark-code"
  project_id = var.project_id
  location = var.region
}