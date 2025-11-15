# Senior DevOps Exam – Implementation Summary (Compact Version)

This file provides a concise summary of **where each requirement in the exam is implemented** in the project structure.

---

## 📁 Implementation Map

### **IIS / Windows Setup**
| Requirement | Where Implemented |
|------------|-------------------|
| IIS Web-Server | roles/iis_base/tasks/main.yml |
| Web-Mgmt-Console | Included via IIS sub‑features |
| NET-Framework-Features | roles/iis_base/tasks/main.yml |
| Web-Asp-Net45 | roles/iis_base/tasks/main.yml |
| NET-WCF-TCP-PortSharing45 | Included via sub‑features |
| Web-Asp | roles/iis_base/tasks/main.yml |
| Web-Windows-Auth | roles/iis_base/tasks/main.yml |
| Web-Http-Redirect | roles/iis_base/tasks/main.yml |
| dotnet-hosting-8.0.16-win | roles/iis_base/tasks/main.yml (download + install) |
| AWS CLI v2 (on controller) | Pre-installed / validated in roles/db_migrations/tasks/main.yml |

---

### **System Environment Variables**
| Requirement | Where Implemented |
|------------|-------------------|
| CQ_DB_LIST | Created automatically via Secrets Manager (no manual env needed) |
| RDS Secret structure (username, password, port, url, name) | Stored in AWS Secrets Manager → fetched in roles/db_migrations/tasks/main.yml |

---

### **Application Configuration**
| Requirement | Where Implemented |
|------------|-------------------|
| Deploy LogViewer.zip | roles/logviewer_app/tasks/main.yml |
| Configure IIS App Pool + Site | roles/logviewer_app/tasks/main.yml |
| health.html | roles/logviewer_app/tasks/main.yml |
| Fix SPA assets base path in index.html | roles/logviewer_app/tasks/main.yml |
| appConfig.json (apiUrl + version) | roles/logviewer_app/tasks/main.yml |

---

### **Database**
| Requirement | Implementation Location |
|------------|--------------------------|
| Fetch DB secret from Secrets Manager | roles/db_migrations/tasks/main.yml |
| Parse JSON into variables | roles/db_migrations/tasks/main.yml |
| Run SQL migrations | roles/db_migrations/tasks/main.yml |

---

### **Blue/Green Deployment**
| Action | Where Implemented |
|--------|-------------------|
| ALB health check | roles/blue_green_switch/tasks/main.yml |
| Switch listener to green | roles/blue_green_switch/tasks/main.yml |
| Deployment log | roles/blue_green_switch/tasks/main.yml |

---

### **Monitoring & Validation**
| Requirement | Where Implemented |
|------------|-------------------|
| Validate IIS via ALB | roles/monitoring_validation/tasks/main.yml |
| TCP SQL connectivity test | roles/monitoring_validation/tasks/main.yml |
| Schema validation placeholder | roles/monitoring_validation/tasks/main.yml |
| CloudWatch logging | roles/monitoring_validation/tasks/main.yml |
| SNS optional alerts | roles/monitoring_validation/tasks/main.yml |
| Automatic rollback to blue | roles/monitoring_validation/tasks/main.yml |

---

### **Terraform Infrastructure**
| Resource | File |
|----------|------|
| EC2 Instances (blue/green) | main.tf |
| RDS SQL Server | rds.tf |
| ALB + Listener + Target Groups | alb.tf |
| Security Groups | security.tf |
| Secrets Manager | secrets.tf |
| IAM Roles (SSM + SecretsManager) | iam.tf |
| Outputs for Ansible (listener ARN, TGs, ALB DNS, instance IDs) | outputs.tf |

---

### **Bonus Requirements (Implemented)**
| Bonus Item | Status | Where Implemented |
|------------|--------|-------------------|
| Ansible Vault fallback secrets | ✔️ | group_vars/logviewer.vault.yml + db_migrations role |
| Rollback on failure | ✔️ | roles/monitoring_validation/tasks/main.yml |
| AWS SSM Session Manager | ✔️ | iam.tf (instance profile) |
| IAM roles (no hardcoded creds) | ✔️ | iam.tf + Terraform outputs |
| Autoscaling group | ❌ Not required / not implemented |

---

This file is intentionally brief and practical so an interviewer can quickly understand the implementation map.
