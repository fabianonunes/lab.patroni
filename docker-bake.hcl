group "default" {
  targets = ["patroni", "backup", "metrics"]
}

variable "IMAGE_REPOSITORY" {
  default = "registry.boo.eth0.work/library"
}

variable "IMAGE_TAG" {
  default = "latest"
}

target "patroni" {
  dockerfile = "patroni.Dockerfile"
  tags = ["${IMAGE_REPOSITORY}/patroni:${IMAGE_TAG}"]
  output = ["type=registry"]
}

target "backup" {
  dockerfile = "backup.Dockerfile"
  tags = ["${IMAGE_REPOSITORY}/patroni-backup:${IMAGE_TAG}"]
  output = ["type=registry"]
}

target "metrics" {
  dockerfile = "metrics.Dockerfile"
  tags = ["${IMAGE_REPOSITORY}/patroni-metrics:${IMAGE_TAG}"]
  output = ["type=registry"]
}
