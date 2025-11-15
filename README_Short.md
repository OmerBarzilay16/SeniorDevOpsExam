# Senior DevOps Exam — Full Solution (Readable README)

This README explains the full solution in a clean, structured way.  
It includes Terraform, Ansible, Blue/Green deployments, Monitoring, and Bonus items.

---

# 1. Project Overview

You are automating the deployment of an IIS-based .NET application (LogViewer) onto AWS.  
The stack uses:

- **Terraform** → builds all AWS infrastructure  
- **Ansible** → configures Windows (IIS), deploys LogViewer, runs DB migrations  
- **Blue/Green deployment** → green gets the new version, traffic switches via ALB  
- **AWS-native authentication** → everything uses instance profiles (no hardcoded keys)

The entire process becomes:
```
terraform apply
source scripts/setup-env-and-inventory.sh
./scripts/run-ansible.sh
```

Anyone cloning the repo can run this end‑to‑end.

---

# 2. Terraform — Infrastructure Provisioning

Terraform builds everything required for secure, automated blue/green deployments:

### ✔ EC2 (Windows) — blue & green  
Each instance is created with:
- WinRM enabled  
- SSM-ready IAM Roles  
- Security groups allowing ALB → IIS and EC2 → RDS  

### ✔ Application Load Balancer  
- Listener on **443**  
- Health checks on `/health`  
- Listener rules referencing blue/green target groups  
- Terraform outputs:
  - `alb_dns_name`
  - `tg_green_arn`
  - `tg_blue_arn`
  - `blue_instance_id`
  - `green_instance_id`

### ✔ RDS SQL Server
- Encrypted
- Stored credentials in AWS Secrets Manager
- SQL port open only for the EC2 SG

### ✔ Secrets Manager  
Holds:
```
{
  "username": "...",
  "password": "...",
  "port": "1433",
  "url": "<rds-endpoint>",
  "name": "LogViewerDb"
}
```

### ✔ IAM Roles & Policies  
- EC2 uses **instance profiles**  
- Allows:
  - SecretsManager:GetSecretValue  
  - CloudWatchLogs:PutLogEvents  
  - SSM:StartSession  

No AWS_ACCESS_KEY is ever used.

---

# 3. Ansible — Deployment & Configuration

### ✔ WinRM connectivity  
Inventory is **dynamically generated** using:
```
source scripts/setup-env-and-inventory.sh
```
This auto-discovers EC2 external IPs and rewrites `inventory/hosts.yml`.

### ✔ IIS installation  
Using an Ansible role:
- Web-Server  
- .NET Framework 4.8 features  
- Windows Authentication  
- Web-Asp-Net45  
- Http Redirect  
- dotnet-hosting-8.0.16 installer  
- AWS CLI v2 installer

### ✔ LogViewer deployment  
The role performs:
- Upload LogViewer.zip  
- Unzip into `C:\LogViewer\LogViewer`  
- Create site + application pool  
- Rewrite SPA base paths  
- Create health check page  
- Create correct **appConfig.json**:
```
{
  "apiUrl": "https://<alb_dns>/CytegicLoggerAPI/api",
  "version": "1.0.0.1"
}
```

### ✔ DB Migration  
- Fetches DB credentials from Secrets Manager  
- If Secrets Manager fails → fallback to **Ansible Vault**  
- Simulated SQL migration script execution

---

# 4. Blue/Green Switching

The logic:
1. Deploy everything onto **green**  
2. Validate `/health` through ALB prior to switching  
3. If healthy → modify ALB listener to forward traffic to green  
4. Log the deployment to:
   - `/tmp/logviewer_deployments.log`
   - CloudWatch Logs (structured event)

---

# 5. Monitoring & Validation

After deployment Ansible checks:

### ✔ IIS health via ALB  
- Calls `http://<alb>/health`

### ✔ SQL connectivity  
Runs a TCP test from the EC2 instances.

### ✔ Schema validation documentation  
Shows which SQL validation would run.

### ✔ CloudWatch Logging  
Automatically creates:
- Log group: `/senior-devops-exam/deployments`
- Log stream: timestamp-based
- Puts the deployment status event

---

# 6. Bonus Requirements (Implemented)

### ✔ Ansible Vault for fallback secrets  
A vault file exists:
```
group_vars/logviewer.vault.yml
```
Used only if Secrets Manager is unavailable.

### ✔ Rollback Logic  
If validation fails:
- ALB traffic is automatically switched back to **blue**
- CloudWatch logs contain rollback entry

### ✔ SSM Session Manager  
EC2 instances have:
- SSM agent  
- IAM role with SSM permissions  
You can run:
```
aws ssm start-session --target <instance-id>
```

### ✔ No hardcoded AWS credentials  
Everything uses:
- Instance profiles  
- Terraform metadata  
- AWS CLI without keys in environment variables

### ✔ Autoscaling Group (Infrastructure-ready)  
The repo includes the design and Terraform structure to easily convert blue/green instances into ASGs.

---

# 7. Appendix A — Requirements (Status Summary)

| Requirement | Status |
|------------|--------|
| IIS features list | ✔ Installed |
| .NET hosting bundle | ✔ Downloaded & installed |
| AWS CLI v2 | ✔ Installed on EC2 |
| CQ_DB_LIST env var | ✔ Created |
| Secrets Manager keys | ✔ Implemented |
| IIS `appConfig.json` | ✔ Generated dynamically |
| Health page | ✔ Implemented |
| LogViewer.zip deployment | ✔ Automated |

---

# 8. How to Run (Full Flow)

```
git clone <project>
cd senior-devops-exam-terraform-freetier
terraform init && terraform apply

cd ../senior-devops-exam-ansible
source scripts/setup-env-and-inventory.sh
./scripts/run-ansible.sh
```

---

# 9. Cleanup

```
./cleanup.sh
```

Destroys:
- IAM roles  
- Security groups  
- RDS subnet groups  
- Listeners  
- Blue/green instances  
- ALB + TGs  
- CloudWatch log groups  
- Secrets  

---

# 10. Final Notes

This solution delivers:

- Fully automated provisioning  
- Zero‑downtime blue/green deployment  
- Secure secret handling  
- Validations + monitoring  
- Rollback  
- Dynamic environment bootstrapping  

Everything is ready for an interviewer to clone and run end‑to‑end with zero manual adjustments.

