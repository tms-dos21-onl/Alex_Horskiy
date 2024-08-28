Project Diplom DOS21

```bash
Diplom_DOS21/
├── ansible/
│   ├── playbooks/
│   │   ├── deploy.yml
│   │   ├── install_dependencies.yml
│   │   ├── setup_vm.yml
│   └── inventories/
│       ├── production/
│       │   └── hosts
│       └── staging/
│           └── hosts
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── provider.tf
├── .gitlab-ci.yml
├── Dockerfile
├── docker-compose.yml
├── README.md
└── scripts/
    ├── build.sh
    ├── test.sh
    ├── apply_infrastructure.sh
    └── deploy.sh

```
