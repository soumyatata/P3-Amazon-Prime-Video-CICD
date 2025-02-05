# **Project Overview**

This project demonstrates deploying an Amazon Prime clone using a set of DevOps tools and practices. The primary tools include:

- **Terraform**: Infrastructure as Code (IaC) tool to create AWS infrastructure such as the EKS cluster.
- **GitHub**: Source code management.
- **Jenkins**: CI/CD automation tool.
- **SonarQube**: Code quality analysis and quality gate tool.
- **NPM**: Build tool for NodeJS.
- **Aqua Trivy**: Security vulnerability scanner.
- **Docker**: Containerization tool to create images.
- **AWS ECR**: Repository to store Docker images.
- **AWS EKS**: Container management platform.
- **ArgoCD**: Continuous deployment tool.
- **Prometheus & Grafana**: Monitoring and alerting tools.

## **Setup Instructions**

### **Create EC2 Instance**

1. Launch an **AWS T2 Large Instance** using **Ubuntu** as the image.
2. Create a new key pair or use an existing one for SSH access.
3. In the **Security Group**, enable HTTP and HTTPS settings and open all ports (for learning purposes only, not recommended in production).

### **Setup Jenkins on EC2**

1. SSH into the EC2 instance.

    For all required packages refer to this [Install Required Packages](https://github.com/soumyatata/P3-Amazon-Prime-Video-CICD/blob/main/script.sh)

2. Unlock Jenkins using an administrative password and install the suggested plugins.
   - **Eclipse Temurin Installer** (Install without restart).
   - **SonarQube Scanner** (Install without restart).
   - **NodeJS Plugin** (Install without restart).

For detailed steps on Jenkins setup & Sonarqube, refer to this [guide](https://mrcloudbook.com/deploying-2048-game-on-docker-and-kubernetes-with-jenkins-ci-cd/).

### **AWS CLI Configuration**

Configure AWS CLI with your **access key** and **secret key**:

```bash

   aws configure
```
### **Clone the Project**

1. Clone the project repository from GitHub:

```bash

    git clone https://github.com/soumyatata/P3-Amazon-Prime-Video-CICD.git

```

### **Terraform Setup for EKS Cluster**

1. Navigate to 

```bash
    cd terraform/eks_node
```

2. Initialize Terraform:

```bash
    terraform init
```
3. Apply Terraform configuration to create the EKS cluster:

```bash    
    terraform apply --auto-approve
```
    
### **Jenkins Pipeline Overview**
    
The CI/CD pipeline consists of several stages:

**Step 1** Git Checkout: 
    Clones the source code from GitHub.
**Step 2:**SonarQube Analysis: 
    Performs static code analysis.
**Step 3:**Quality Gate: Ensures code quality standards are met.
**Step 4:**Trivy Security Scan: Scans the project for vulnerabilities.
**Step 5:**Docker Build: Builds a Docker image for the project.
**Step 6:**Push to AWS ECR: Tags and pushes the Docker image to ECR.
**Step 7:**Image Cleanup: Deletes images from the Jenkins server to save space.
**Step 8:**Deploy to EKS
**Step 9:**After the pipeline is built, log in to EKS and deploy the application.
**Step 10:**Monitoring Setup
    Integrate Prometheus and Grafana for monitoring.
    Configure Prometheus to collect metrics and Grafana to visualize them.
**Step 11:**Pipeline Cleanup
    To delete the resources such as load balancers, services, and deployment files.

Use terraform destroy to remove the EKS cluster and other infrastructure.

cd terraform/eks_node

```bash
    terraform destroy --auto-approve
```
**Create a Jenkins Pipeline**

1️⃣ Go to Jenkins Dashboard → New Item → Pipeline.

2️⃣ Add the following pipeline script:

Click on 'Build Now' in Jenkins.


📢 Let's Connect!

If you have any questions or suggestions, feel free to reach out. Contributions are welcome!

🔗 **GitHub:** [AMAZON-PRIME-APP](https://github.com/soumyatata/P3-Amazon-Prime-Video-CICD)

🔗 **LinkedIn:** [SoumyaTata](https://www.linkedin.com/in/t-soumya/)

🚀 Happy Coding & DevOps Journey! 🚀