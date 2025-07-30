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
  target = "patroni"
  tags = ["${IMAGE_REPOSITORY}/patroni:${IMAGE_TAG}"]
  output = ["type=registry"]
}

target "backup" {
  target = "backup"
  tags = ["${IMAGE_REPOSITORY}/patroni-backup:${IMAGE_TAG}"]
  output = ["type=registry"]
}

target "metrics" {
  target = "metrics"
  tags = ["${IMAGE_REPOSITORY}/patroni-metrics:${IMAGE_TAG}"]
  output = ["type=registry"]
}
