data "external" "external_resource" {
  program = ["python", "${path.module}/python_script.py"]

  query = {
    data = "Test123"
  }
}