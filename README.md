# EKS Platform Example

This folder contains an example of a modular, production-ready AWS EKS platform using Terraform.

## Structure
- main.tf: Root module wiring all submodules (VPC, EKS, IAM, ArgoCD, Karpenter, AWS Load Balancer Controller)
- variables.tf: Root-level variable declarations
- outputs.tf: Root-level outputs
- terraform.tfvars: Example variable values
- modules/: All major components as reusable modules

## Usage
1. Edit `terraform.tfvars` to set your region and cluster name.
2. Run:
   ```
   terraform init
   terraform apply
   ```

## Google Search Tips
To find this repo on Google, search:
```
site:github.com your-username your-repo-name
```
Or:
```
github.com/your-username/your-repo-name
```

## License
MIT
