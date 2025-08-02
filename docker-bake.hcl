group "default" {
  targets = ["patroni", "pgbouncer", "backup", "metrics"]
}

variable "IMAGE_REPOSITORY" {
  default = "localhost/patroni"
}

variable "IMAGE_TAG" {
  default = "latest"
}

variable "IMAGE_TARGET" {
  default = "docker"
}

target common {
  output = ["type=docker"]
}

target base {
  target = "base"
}

target custom {
  dockerfile = "Dockerfile.custom"
  contexts = {
    base = "target:base"
  }
}

target "patroni" {
  inherits = ["common"]
  contexts = {
    custom = "target:custom"
  }
  target = "patroni"
  tags = ["${IMAGE_REPOSITORY}:${IMAGE_TAG}"]
}

target "pgbouncer" {
  inherits = ["common"]
  target = "pgbouncer"
  tags = ["${IMAGE_REPOSITORY}-pgbouncer:${IMAGE_TAG}"]
}

target "backup" {
  inherits = ["common"]
  target = "backup"
  tags = ["${IMAGE_REPOSITORY}-backup:${IMAGE_TAG}"]
}

target "metrics" {
  inherits = ["common"]
  target = "metrics"
  tags = ["${IMAGE_REPOSITORY}-metrics:${IMAGE_TAG}"]
}
