group "default" {
  targets = ["patroni", "pgbouncer", "backup", "metrics"]
}

variable "IMAGE_REPOSITORY" {
  default = "localhost"
}

variable "IMAGE_TAG" {
  default = "latest"
}

variable "IMAGE_TARGET" {
  default = "docker"
}

target postgresql {
  dockerfile = "Dockerfile.postgres"
}

target base {
  contexts = {
    baseimage = "target:postgresql"
  }
}

target common {
  output = ["type=docker"]
}

target "patroni" {
  inherits = ["common", "base"]
  target = "patroni"
  tags = ["${IMAGE_REPOSITORY}/patroni:${IMAGE_TAG}"]
}

target "pgbouncer" {
  inherits = ["common", "base"]
  target = "pgbouncer"
  tags = ["${IMAGE_REPOSITORY}/patroni-pgbouncer:${IMAGE_TAG}"]
}

target "backup" {
  inherits = ["common", "base"]
  target = "backup"
  tags = ["${IMAGE_REPOSITORY}/patroni-backup:${IMAGE_TAG}"]
}

target "metrics" {
  inherits = ["common"]
  target = "metrics"
  tags = ["${IMAGE_REPOSITORY}/patroni-metrics:${IMAGE_TAG}"]
}
