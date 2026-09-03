# AWS 3-Tier Architecture with Terraform

A production-style **3-tier AWS architecture** provisioned entirely with **Terraform**, built using **custom reusable modules** — one dedicated module folder per resource type (`vpc`, `ec2`, `alb`, `rds`).

---

## 🖼️ Architecture Diagram

![3-Tier Architecture Diagram](./screenshots/architecture-diagram.png)

*VPC `dev-custom-vpc` (10.0.0.0/16) — 2 Availability Zones, 8 subnets, External + Internal ALB, security-group chain from Internet down to RDS.*

---

## 🏗️ Architecture Overview

- **VPC:** `dev-custom-vpc` — `10.0.0.0/16`
- **Availability Zones:** 2 (`us-east-1a`, `us-east-1b`)
- **Subnets:** 8 total (Public, App/Private, DB/Private — 2 AZs each)
- **Load Balancers:** External ALB (internet-facing) + Internal ALB (private)

### Tiers

| Tier | Subnets | Route | Resources |
|------|---------|-------|-----------|
| **Public** | dev-public-1, dev-public-2 | `0.0.0.0/0 → IGW` | Internet Gateway, NAT Gateway + EIP, Bastion Host + EIP, External ALB |
| **App / Private** | dev-app-1 to dev-app-4 | `0.0.0.0/0 → NAT Gateway` | Frontend-1, Frontend-2, Backend-1, Backend-2, Internal ALB |
| **DB / Private** | dev-db-1, dev-db-2 | Isolated — no internet route | RDS MySQL (Multi-AZ subnet group) |

### Traffic Flow

```
Internet → External ALB (Public Subnet) → Internal ALB (App Subnet)
         → Frontend/Backend EC2 instances → RDS MySQL (DB Subnet, port 3306)
```

Admin access to private instances is via a **Bastion Host** in the public subnet (SSH only from an allow-listed Admin IP).

---

## 🔐 Security Group Chain

Traffic is only allowed to flow one hop at a time down the security group chain — nothing skips a layer:

```
Internet (0.0.0.0/0)
   │  HTTP 80
   ▼
ext-alb-sg        (in: 80 from Internet)
   │
   ▼
app-tier-sg       (in: 80 from ext-alb-sg, in: 22 from bastion-sg)
   │
   ▼
int-alb-sg        (in: 80 from ext-alb-sg)
   │
   ▼
rds-sg            (in: 3306 from app-tier-sg)
```

---

## 📁 Project Structure

Each AWS resource type is isolated into its own Terraform module for reusability and clean separation of concerns:

```
3-tier-infra/
├── main.tf              # Root module — calls all child modules
├── provider.tf           # AWS provider config
├── variable.tf           # Root-level variables
├── output.tf              # Root-level outputs
├── terraform.tfvars       # Variable values (gitignored)
├── vpc/                  # VPC, subnets, route tables, IGW, NAT
│   ├── vpc.tf
│   ├── variable.tf
│   └── output.tf
├── ec2/                  # Frontend, Backend, Bastion instances
│   ├── ec2.tf
│   ├── install_nginx.sh
│   ├── variable.tf
│   └── output.tf
├── alb/                  # External + Internal Application Load Balancers
│   ├── alb.tf
│   ├── variable.tf
│   └── output.tf
├── RDS/                  # MySQL RDS instance + subnet group
│   ├── rds.tf
│   ├── variable.tf
│   └── output.tf
└── .gitignore
```

---

## ⚙️ Tech Stack

- **IaC:** Terraform
- **Cloud:** AWS (VPC, EC2, ALB, RDS, NAT Gateway, IGW)
- **Web Server:** Nginx (via `user_data` bootstrap script)
- **Database:** MySQL (Amazon RDS)

---

## 📸 AWS Console Screenshots

### VPC & Subnets
![VPC Overview](./screenshots/vpc-overview.webp)
Custom VPC `dev-custom-vpc` with 8 subnets split across public, app, and DB tiers.

![Subnets](./screenshots/subnets.webp)
All 8 subnets (public, app, db) across `us-east-1a` and `us-east-1b`.

### Routing & Gateways
![Route Tables](./screenshots/route-tables.webp)
Route tables — main, `dev-public-rt`, `dev-db-rt`.

![Internet Gateway](./screenshots/internet-gateway.webp)
`dev-public-igw` attached to the VPC.

![NAT Gateway](./screenshots/nat-gateway.webp)
`dev-nat` — enables outbound internet access for the private app tier.

### Compute
![EC2 Instances](./screenshots/ec2-instances.webp)
Running instances: Frontend-1, Frontend-2, Backend-1, Backend-2, Bastion Host.

### Security
![Security Groups](./screenshots/security-groups.webp)
Security groups managed by Terraform — `ext-alb-sg`, `int-alb-sg`, `app-tier-sg`, `rds-sg`, `bastion-sg`.

### Load Balancing
![Load Balancers](./screenshots/alb.webp)
External (internet-facing) and Internal ALB, both active across 2 AZs.

### Database
![RDS Database](./screenshots/rds-database.webp)
MySQL RDS instance, `Available`, deployed in the isolated DB subnet group.

---

## 🚀 Deployment

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## 🧹 Cleanup

```bash
terraform destroy --auto-approve
```

---

## 📌 Notes

- All resources are provisioned across 2 Availability Zones for high availability.
- State files, `.tfvars`, and key pairs are excluded from version control via `.gitignore`.
- Security groups are chained rather than flat — each tier only accepts traffic from the specific SG one layer above it.
