terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
    gcp = {
        source = "hashicorp/google"
    }
    azure = {
        source = "hashicorp/azurerm"
    }
  }
}

resource "google_pubsub_topic" "x" {
  name = "test-topic"
  project = "my-project"
  partition_config {
    count = 1
    capacity {
      publish_mib_per_sec = 4
      subscribe_mib_per_sec = 8
    }
  }

  retention_config {
    per_partition_bytes = 32212254720
  }

  schema_settings {
    schema = "projects/my-project-name/schemas/x"
    encoding = "JSON"
  }
}

resource "google_pubsub_schema" "x" {
  name = "y"
  type = "PROTOCOL_BUFFER"
  definition = "syntax = \"proto3\";\nmessage Results {\nstring message_request = 1;\nstring message_response = 2;\nstring timestamp_request = 3;\nstring timestamp_response = 4;\n}"
}

resource "google_pubsub_lite_subscription" "x" {
  name  = "z"
  topic = "y"
  delivery_config {
    delivery_requirement = "DELIVER_AFTER_STORED"
  }
}

data "google_project" "project" {
}

resource "aws_instance" "instance" {
    ami = "ami-0afd879ef978cb098798"
    instance_type = "t2.micro"
    tags = {
      name = "Name"
    }
}
  
resource "aws_s3_bucket" "bucket" {
    bucket = "bucket"
}

resource "aws_s3_bucket_object" "object" {
    bucket = "bucket"
    key = "file.txt"
    source = "./file.txt"
}

data "aws_rds_engine_version" "default" {
  engine = "db2-se"
}

data "aws_rds_orderable_db_instance" "x" {
  engine                     = "db2-se"
  engine_version             = "11.5"
  license_model              = var.aws_rds_orderable_db_instance_license_model
  storage_type               = "gp3"
  preferred_instance_classes = ["db.t3.small", "db.r6i.large", "db.m6i.large"]
}

resource "aws_db_parameter_group" "x" {
  name   = "db-db2-params"
  family = var.aws_db_parameter_group_family

  parameter {
    apply_method = "immediate"
    name         = "rds.ibm_customer_id"
    value        = 0000000000
  }
  parameter {
    apply_method = "immediate"
    name         = "rds.ibm_site_id"
    value        = 0000000000
  }
}

variable "aws_db_parameter_group_family" {
}

variable "aws_rds_orderable_db_instance_license_model" {
}

resource "aws_db_instance" "x" {
  allocated_storage       = 1
  backup_retention_period = 0
  db_name                 = "test"
  engine                  = "db2-se"
  engine_version          = "11.5"
  identifier              = "db2-instance-demo"
  instance_class          = "db.t3.standard"
  parameter_group_name    = "db-db2-params"
  password                = "Hell.Yeah.420.69!!"
  username                = "root"
}

resource "google_artifact_registry_repository" "my-repo-upstream-1" {
  location      = "us-central1"
  repository_id = "my-repository-upstream-1"
  description   = "example docker repository (upstream source) 1"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "my-repo-upstream-2" {
  location      = "us-central1"
  repository_id = "my-repository-upstream-2"
  description   = "example docker repository (upstream source) 2"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "my-repo" {
  depends_on    = []
  location      = "us-central1"
  repository_id = "my-repository"
  description   = "example virtual docker repository"
  format        = "DOCKER"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id          = "my-repository-upstream-1"
      repository  = google_artifact_registry_repository.my-repo-upstream-1.id
      priority    = 20
    }
    upstream_policies {
      id          = "my-repository-upstream-2"
      repository  = google_artifact_registry_repository.my-repo-upstream-2.id
      priority    = 10
    }
  }
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = "my-gke-cluster"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_service_account" "default_2" {
  account_id   = "service-account-id2"
  display_name = "Service Account2"
}

resource "google_container_cluster" "primary_2" {
  name     = "my-gke-cluster_2"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes_2" {
  name       = "my-node-pool_2"
  location   = "us-central1"
  cluster    = "my-gke-cluster"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = google_service_account.default_2.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_service_account" "default_3" {
  account_id   = "service-account-id3"
  display_name = "Service Account3"
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/22"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = "192.168.0.0/24"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block        = "192.168.1.0/24"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_az3" {
  availability_zone = data.aws_availability_zones.azs.names[2]
  cidr_block        = "192.168.2.0/24"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_kms_key" "kms" {
  description = "example"
}

resource "aws_cloudwatch_log_group" "test" {
  name = "msk_broker_logs"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "msk-broker-logs-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_test_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  name        = "terraform-kinesis-firehose-msk-broker-logs-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn
  }

  tags = {
    LogDeliveryEnabled = "placeholder"
  }

  lifecycle {
    ignore_changes = [
      tags["LogDeliveryEnabled"],
    ]
  }
}

resource "aws_msk_cluster" "example" {
  cluster_name           = "example"
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = [
      aws_subnet.subnet_az1.id,
      aws_subnet.subnet_az2.id,
      aws_subnet.subnet_az3.id,
    ]
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    security_groups = [aws_security_group.sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
      firehose {
        enabled         = true
        delivery_stream = aws_kinesis_firehose_delivery_stream.test_stream.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  tags = {
    foo = "bar"
  }
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.example.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.example.bootstrap_brokers_tls
}

resource "google_container_cluster" "primary3" {
  name     = "my-gke-cluster3"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes-3" {
  name       = "my-node-pool3"
  location   = "us-central1"
  cluster    = "my-gke-cluster"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
