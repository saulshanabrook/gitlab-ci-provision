resource "aws_key_pair" "deploy" {
  key_name = "deploy"
  public_key = "${file(\"../ssh/id_rsa.pub\")}"
}
