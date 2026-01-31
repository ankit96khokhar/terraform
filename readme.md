# 📘 Multi-Tenant Terraform + Jenkins Architecture
**Bank / Enterprise Grade | Secure | Scalable | Auditable**

---

## 📌 Overview

This repository documents a **production-grade, multi-tenant Terraform and CI/CD architecture** designed for banks and large enterprises.

The system supports:
- Multiple **Business Units (Tenants)**
- Multiple **applications per tenant**
- Multiple **environments** (dev / test / prod)
- Multiple **AWS regions**
- Strong **security isolation**
- **Centralized Jenkins** with **no static credentials**

---

## 🧭 Core Terminology

| Term | Meaning |
|----|----|
Tenant | Business Unit (BU) |
Project | Application / Service |
Environment | dev / test / prod |
Management Account | Central platform / CI account |
Tenant Account | BU environment account |

---

## 🧱 High-Level Design Principles

- Each **environment runs in a separate AWS account**
- Terraform state is **never shared**
- CI/CD uses **OIDC + IRSA**, not IAM users
- All AWS access is via **AssumeRole**
- Blast radius is minimized by design

---

## 🏗️ Architecture Diagram (System View)

                    ┌──────────────────────────────┐
                    │   Management AWS Account     │
                    │                              │
                    │   ┌──────────────────────┐  │
                    │   │  EKS Cluster          │  │
                    │   │                      │  │
                    │   │  ┌────────────────┐  │  │
                    │   │  │ Jenkins Pod    │  │  │
                    │   │  │ (IRSA / OIDC)  │  │  │
                    │   │  └───────┬────────┘  │  │
                    │   │          │            │
                    │   └──────────┼────────────┘
                    │              │
                    │   IAM Role:  │
                    │   jenkins-base-role
                    │              │
                    └──────────────┼────────────────
                                   │ sts:AssumeRole
    ───────────────────────────────┼──────────────────────────────
                                   │
    ┌──────────────────────────────┴──────────────────────────────┐
    │                       Tenant AWS Accounts                    │
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │ tenant-a-dev (AWS Account)                            │   │
    │  │                                                      │   │
    │  │  IAM Role: terraform-ci-role                          │◄───┘
    │  │                                                      │
    │  │  Terraform Backend                                   │
    │  │  ├─ S3: tf-state-tenant-a-dev                         │
    │  │  └─ DynamoDB: terraform-locks                         │
    │  │                                                      │
    │  │  App Infra (VPC / EKS / RDS / etc.)                   │
    │  └──────────────────────────────────────────────────────┘
    │
    │  ┌──────────────────────────────────────────────────────┐
    │  │ tenant-a-prod (AWS Account)                           │
    │  │  (same structure as dev)                              │
    │  └──────────────────────────────────────────────────────┘
    └──────────────────────────────────────────────────────────────┘


---

## 🔐 Credential Flow (Security-Critical)

[Jenkins Pod on EKS]
|
| (OIDC / IRSA)
v
[jenkins-base-role]
(Management Account)
|
| sts:AssumeRole
v
[terraform-ci-role]
(Tenant Account)
|
v
[Terraform CLI]
|
v
[S3 Backend + DynamoDB Lock]


### Guarantees
- ❌ No AWS access keys
- ❌ No IAM users in CI/CD
- ✅ Short-lived credentials only
- ✅ Full CloudTrail auditability

---

## 🗂️ Account & Environment Strategy
Tenant (Business Unit)
└── Environment (AWS Account)
├── Dev
├── Test
└── Prod

✔ Dev / Test / Prod are **never in the same account**  
✔ Hard isolation is enforced by AWS boundaries  

---

## 📦 Terraform State Architecture

### Rules
- ❌ No Terraform workspaces
- ❌ No shared state
- ✅ One S3 bucket per AWS account
- ✅ One DynamoDB table per AWS account
- ✅ One Terraform state per project per region

### State Key Format

<tenant>/<project>/<region>/terraform.tfstate


### Example

tenant-a/payments/us-east-1/terraform.tfstate


---

## 🗃️ Terraform State Layout (Visual)

tf-state-tenant-a-prod
└── tenant-a/
├── payments/
│ ├── us-east-1/
│ │ └── terraform.tfstate
│ └── eu-west-1/
│ └── terraform.tfstate
├── search/
│ └── us-east-1/
│ └── terraform.tfstate
└── platform/
└── ap-south-1/
└── terraform.tfstate


---

## 🔧 Bootstrap Strategy

### Org Bootstrap (Optional)
- AWS Organizations account creation
- Often **manual in banks**
- Terraform code exists but commented

### Account Bootstrap (Mandatory)
Runs once per AWS account:
- S3 bucket for Terraform state
- DynamoDB table for state locking
- `terraform-ci-role` IAM role

---

## 🔐 IAM Role Design

### Management Account
**Role:** `jenkins-base-role`
- Bound to Jenkins pod via IRSA
- Can only call `sts:AssumeRole`
- No infrastructure permissions

### Tenant Accounts
**Role:** `terraform-ci-role`
- Trusted by `jenkins-base-role`
- Owns Terraform backend
- Manages application infrastructure

---

## 🚀 Jenkins Pipeline Behavior

- Single shared pipeline
- Fully parameterized:
  - TENANT
  - ENV
  - PROJECT
  - REGION
  - ACTION (plan / apply / destroy)
- Destroy blocked for prod
- Explicit confirmation for destructive actions

---

## 🧠 Interview Cheat Sheet

### One-Liners (Memorize)

- “Each business unit is treated as a tenant.”
- “We isolate environments using separate AWS accounts.”
- “Terraform state is isolated per application and region.”
- “Jenkins uses IRSA and OIDC, not IAM users.”
- “All AWS access is via short-lived assume-role credentials.”

---

### Common Questions

**Q: How do you manage Terraform for 30–40 tenants?**  
A: Separate AWS accounts per environment and isolated Terraform state per project and region.

**Q: Why not Terraform workspaces?**  
A: Workspaces don’t provide strong isolation or ownership boundaries.

**Q: How does Jenkins authenticate to AWS?**  
A: Jenkins runs on EKS using IRSA and assumes roles into tenant accounts.

**Q: Why OIDC over IAM users?**  
A: OIDC eliminates long-lived credentials and improves auditability.

---

## 🏁 Final Summary

> We built a multi-tenant Terraform platform with isolated AWS accounts per environment, isolated state per application and region, and centralized Jenkins on EKS using OIDC and cross-account assume-role. This design provides strong security, auditability, and scalability.

---

## 🔜 Future Enhancements

- Project-level IAM policies
- Prod approval workflows
- SCP guardrails
- Multi-region DR promotion
- GitOps integration (ArgoCD)

---

**Status:** ✅ Production-ready, bank-approved architecture
