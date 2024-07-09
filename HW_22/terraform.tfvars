project_id  = "your-gcp-project-id"
region      = "us-central1"
network_name = "terraform-network"

subnets = [
  {
    name          = "subnetwork-a"
    ip_cidr_range = "10.0.1.0/24"
  },
  {
    name          = "subnetwork-b"
    ip_cidr_range = "10.0.2.0/24"
  },
  {
    name          = "subnetwork-c"
    ip_cidr_range = "10.0.3.0/24"
  }
]
