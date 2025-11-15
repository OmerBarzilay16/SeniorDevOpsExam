# Senior DevOps Exam – Automated IIS Deployment on AWS

*(Short, clean, professional summary)*

## Overview
This project implements a fully automated deployment process for the **LogViewer** .NET/IIS application on AWS using **Terraform** (infrastructure) and **Ansible** (deployment & blue‑green orchestration).

## 1. Terraform Infrastructure
Terraform provisions:
- Windows EC2 instances for **blue** and **green** environments  
- Application Load Balancer (ALB) with target groups  
- RDS SQL Server  
- Security groups for HTTP/HTTPS/WinRM/SQL  
- AWS Secrets Manager (DB credentials)  
- IAM roles for EC2, Secrets Manager, SSM, and RDS access  
- No hardcoded AWS credentials anywhere (IAM‑based auth)

## 2. Ansible Deployment Pipeline
Ansible automates:
- WinRM connection to Windows EC2  
- Installation of IIS and required Windows features  
- Installation of .NET Hosting Bundle 8.0.16  
- Deploying and configuring LogViewer  
- Creating IIS site, app pool, and health endpoint  
- Retrieving DB secrets from AWS Secrets Manager  
- Running SQL migration scripts against RDS  
- Performing blue‑green cutover using ALB  
- Logging deployment steps

## 3. Monitoring & Validation
- ALB health check for the deployed app  
- SQL connectivity test (TCP 1433)  
- Schema validation example  
- Logs written to CloudWatch  
- Optional SNS notifications

## 4. Bonus Features Implemented
- **Ansible Vault** – fallback DB credentials  
- **Rollback logic** – if validation fails, ALB is switched back to blue  
- **IAM‑based authentication** – no AWS keys stored anywhere  
- **SSM Session Manager support** – EC2 access without SSH  
- Foundation ready for future **Auto Scaling Group** work

## 5. Setup Script
The helper script:

```
scripts/setup-env-and-inventory.sh
```

Automatically:
- Reads Terraform outputs  
- Sets required environment variables  
- Fetches current EC2 public IPs  
- Updates Ansible inventory  
- Prepares the environment for deployment  

Works cleanly even after a full recreate (`terraform destroy && terraform apply`).

## 6. How to Deploy

### Step 1 — Provision AWS Infra
```
cd senior-devops-exam-terraform-freetier
terraform init
terraform apply -auto-approve
```

### Step 2 — Prepare Ansible Environment
```
cd senior-devops-exam-ansible
source scripts/setup-env-and-inventory.sh
```

### Step 3 — Run Deployment
```
./scripts/run-ansible.sh
```

## Appendix A – Requirements Covered
### IIS Features Installed
- Web-Server  
- Web-Mgmt-Console  
- .NET Framework 4.8  
- ASP.NET 4.5  
- WCF TCP Port Sharing  
- Windows Authentication  
- HTTP Redirect  
- .NET Hosting Bundle 8.0.16  
- AWS CLI v2  

### System Environment Variable
`CQ_DB_LIST` is generated and applied based on the DB secret.

### Secrets Structure
```
{
  "username": "",
  "password": "",
  "port": "1433",
  "url": "",
  "name": "LogViewerDb"
}
```

### LogViewer appConfig.json
Automatically created:
```
{
  "apiUrl": "https://<ALB-DNS>/CytegicLoggerAPI/api",
  "version": "1.0.0.1"
}
```

## Summary
The project now provides a complete, repeatable, production-ready automation pipeline:
- Full infrastructure provisioning  
- Zero-touch deployment  
- Blue‑green switching  
- Monitoring & rollback  
- Secure secret + IAM design  
- One-command deployment after Terraform  

Anyone can clone the repo, run Terraform, source the setup script, and deploy the application with a single command.
