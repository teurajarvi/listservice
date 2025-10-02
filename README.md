# ListService (Serverless, AWS, Terraform, Python)

## 📖 **What is ListService?**

**ListService** is a fully-functional, production-ready serverless REST API that provides two simple but powerful list operations:

- **`head`** - Returns the first `n` elements from a list
- **`tail`** - Returns the last `n` elements from a list

### **Why This Project?**

This project demonstrates **modern cloud-native development best practices**:
- ✅ **Serverless architecture** - No servers to manage, pay only for what you use
- ✅ **Infrastructure as Code** - Entire infrastructure defined in Terraform
- ✅ **Automated testing** - 15 comprehensive test cases
- ✅ **Production-ready** - Includes monitoring, alarms, logging, and throttling
- ✅ **Well-documented** - Complete guide from zero to deployed API

### **Real-World Use Cases**

- **Data pagination** - Get first/last N records from datasets
- **Preview generation** - Show top/bottom items from large collections
- **Microservice pattern** - Reusable list processing component
- **Learning resource** - Complete example of AWS serverless architecture

### **What You'll Learn**

By deploying and studying this project, you'll learn:
- How to build serverless APIs with AWS Lambda and API Gateway
- How to manage cloud infrastructure with Terraform
- How to write testable Python code with proper error handling
- How to implement monitoring and observability in the cloud
- How to deploy production-ready applications to AWS

---

## 🎯 **Project Highlights**

This repository contains the **complete, working implementation** including:
- **Python 3.12 Lambda function** with comprehensive error handling
- **Terraform infrastructure modules** for Lambda, API Gateway, CloudWatch, and more
- **15 automated tests** covering all edge cases
- **OpenAPI 3.0 specification** for API documentation
- **CloudWatch alarms** for monitoring errors and latency
- **Multi-environment support** (dev, staging, production)

See sections below for architecture, API usage, code structure, deployment guide, and troubleshooting.

---

## 🚀 Quick Start

> **✅ Infrastructure Status**: Successfully deployed to AWS!  
> **✅ Tests**: 15/15 passing  
> **✅ Build**: Lambda package ready  
> **✅ AWS Credentials**: Configured and verified  
> **✅ API Endpoint**: `https://uvynvd8xfe.execute-api.eu-north-1.amazonaws.com/dev`  
> **🎯 Status**: LIVE AND RUNNING!  
> **⚠️ Note**: WAF disabled (not supported with HTTP API v2 - see Architecture section)

---

## 🚀 **How to Deploy This to Your Own AWS Account**

Follow this comprehensive step-by-step guide to deploy ListService to your AWS account. No prior AWS experience needed!

### **📋 Prerequisites Checklist**

Before you begin, ensure you have:

1. **Python 3.12 or newer**
   - Check version: `python --version`
   - Download from: https://www.python.org/downloads/
   
2. **Terraform 1.6 or newer**
   - Check version: `terraform --version`
   - Download from: https://www.terraform.io/downloads
   - Windows: Extract to `C:\terraform\` and add to PATH
   
3. **AWS CLI v2**
   - Check version: `aws --version`
   - Download from: https://aws.amazon.com/cli/
   - Windows: https://awscli.amazonaws.com/AWSCLIV2.msi
   
4. **pytest** (for running tests)
   - Install: `pip install pytest`

5. **An AWS Account**
   - Sign up at: https://aws.amazon.com/
   - Free tier eligible for 12 months

6. **Git** (to clone this repository)
   - Download from: https://git-scm.com/downloads

---

### **Step 1️⃣: Clone and Verify the Project**

```powershell
# Clone the repository (replace YOUR-USERNAME with your GitHub username)
git clone https://github.com/YOUR-USERNAME/listservice.git
cd listservice

# Verify project structure
ls
# You should see: src/, infra/, scripts/, tests/, README.md, etc.

# Run tests to verify everything works
python -m pytest src/tests/ -v
# All 15 tests should pass ✅
```

**What this does**: Downloads the project and verifies the code works on your machine before deploying to AWS.

---

### **Step 2️⃣: Build the Lambda Package**

```powershell
# Build the deployment package (creates build/listservice.zip)
python scripts/build_zip.py

# Verify the package was created
ls build/
# You should see: listservice.zip (approximately 2-3 KB)
```

**What this does**: Packages your Python code into a ZIP file that AWS Lambda can run. This includes the `list_service_handler.py` file with all the business logic.

---

### **Step 3️⃣: Set Up AWS Credentials**

If you haven't configured AWS CLI yet, follow these detailed steps:

#### **3.1 Create an IAM User in AWS Console**

1. Go to https://console.aws.amazon.com/ and sign in
2. Search for "IAM" in the top search bar
3. Click **Users** → **Add users**
4. Enter username: `terraform-admin` (or any name you prefer)
5. Click **Next**
6. Select **Attach policies directly**
7. Search and select: **AdministratorAccess**
   - ⚠️ Note: This gives full access. In production, use more restrictive policies.
8. Click **Next** → **Create user**

#### **3.2 Create Access Keys**

1. Click on the user you just created
2. Go to **Security credentials** tab
3. Scroll to **Access keys** section
4. Click **Create access key**
5. Select use case: **Command Line Interface (CLI)**
6. Check the confirmation box
7. Click **Next** → **Create access key**
8. **IMPORTANT**: Copy both:
   - Access Key ID (starts with `AKIA...`)
   - Secret Access Key (long random string)
9. Download the CSV file as backup
10. Click **Done**

#### **3.3 Configure AWS CLI**

```powershell
# Run the configuration command
aws configure

# You'll be prompted for 4 values:
# AWS Access Key ID [None]: <paste your Access Key ID>
# AWS Secret Access Key [None]: <paste your Secret Access Key>
# Default region name [None]: eu-north-1
# Default output format [None]: json
```

**Region choices**:
- `eu-north-1` - Stockholm (used in this example)
- `us-east-1` - N. Virginia
- `eu-west-1` - Ireland
- See full list: https://aws.amazon.com/about-aws/global-infrastructure/regions_az/

#### **3.4 Verify Your Credentials**

```powershell
# This command shows your AWS account info
aws sts get-caller-identity

# Expected output (example):
# {
#     "UserId": "AIDAI23HXS...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
# }
```

If you see your account information, you're ready to proceed! ✅

---

### **Step 4️⃣: Initialize Terraform**

```powershell
# Navigate to infrastructure directory
cd infra

# Initialize Terraform (downloads AWS provider)
terraform init

# Expected output:
# Terraform has been successfully initialized!
```

**What this does**: Downloads the AWS provider plugin (~100MB) that Terraform uses to create AWS resources. This only needs to be done once.

---

### **Step 5️⃣: Review What Will Be Created**

```powershell
# Generate and show execution plan
terraform plan -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"

# This will show ~17 resources to be created:
# - Lambda function (listservice-dev-handler)
# - API Gateway HTTP API (listservice-dev-http-api)
# - IAM roles and policies
# - CloudWatch Log Groups
# - CloudWatch Alarms (3)
# - SNS Topic
```

**What this does**: Shows you exactly what AWS resources Terraform will create. **No resources are created yet** - this is a preview.

**Review carefully**: Look for the resource names, make sure the region is correct.

---

### **Step 6️⃣: Deploy to AWS**

```powershell
# Apply the infrastructure
terraform apply -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"

# Terraform will show the plan again and ask:
# Do you want to perform these actions? 
#   Type: yes

# Deployment takes ~2-3 minutes
# You'll see resources being created in real-time
```

**What this does**: Creates all the AWS resources. This is where your Lambda function, API Gateway, and monitoring are set up in the cloud.

**Cost**: With AWS Free Tier, this costs **$0.40/month** (mostly CloudWatch alarms). See the Cost Estimate section below.

---

### **Step 7️⃣: Get Your API Endpoint**

```powershell
# Display your unique API URL
terraform output api_endpoint

# Example output:
# "https://abc123xyz.execute-api.eu-north-1.amazonaws.com/dev"
```

**What this is**: Your personal, unique URL where your API is running. This is what you'll use to make API calls.

---

### **Step 8️⃣: Test Your Deployed API**

Now test your **own** API endpoint (replace with your actual endpoint from Step 7):

**PowerShell:**
```powershell
# Save YOUR endpoint to a variable (get it from: terraform output api_endpoint)
$API_ENDPOINT = "https://YOUR-UNIQUE-ID.execute-api.eu-north-1.amazonaws.com/dev"

# Test HEAD operation - get first 3 elements
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'

# Expected output:
# result
# ------
# {apple, banana, cherry}

# Test TAIL operation - get last 2 elements
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/tail" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":2}'

# Expected output:
# result
# ------
# {date, elderberry}

# Test edge case - n larger than list length
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{"list":["a","b"],"n":5}'

# Expected output:
# result
# ------
# {a, b}
```

**Unix/Linux/Mac (bash/curl):**
```bash
# Get your endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test HEAD operation
curl -X POST "$API_ENDPOINT/v1/list/head" \
  -H "Content-Type: application/json" \
  -d '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'

# Expected: {"result":["apple","banana","cherry"]}

# Test TAIL operation
curl -X POST "$API_ENDPOINT/v1/list/tail" \
  -H "Content-Type: application/json" \
  -d '{"list":["apple","banana","cherry","date","elderberry"],"n":2}'

# Expected: {"result":["date","elderberry"]}
```

---

### **🎉 Congratulations!**

If you see the expected results above, your API is **successfully deployed and working**! 

You now have:
- ✅ A serverless API running on AWS Lambda
- ✅ An API Gateway endpoint accessible from anywhere
- ✅ CloudWatch monitoring and alarms
- ✅ Infrastructure defined as code (Terraform)

---

### **Step 9️⃣: Explore and Monitor (Optional)**

#### **View Logs**
```powershell
# Watch Lambda logs in real-time
aws logs tail /aws/lambda/listservice-dev-handler --follow
```

#### **Check in AWS Console**
- Lambda Function: https://console.aws.amazon.com/lambda/
- API Gateway: https://console.aws.amazon.com/apigateway/
- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/

#### **Test Error Handling**
```powershell
# Send invalid request (missing required fields)
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{}'

# Expected: HTTP 400 Bad Request with error message
```

---

### **Step 🔟: Clean Up (When Done Testing)**

To avoid ongoing charges, destroy the infrastructure when you're done:

```powershell
# Destroy all AWS resources
cd infra
terraform destroy -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"

# Type: yes when prompted

# Verify everything is deleted
terraform show
# Should show: No State
```

**What this does**: Removes all AWS resources created by Terraform. You won't be charged for anything after this.

---

## 📚 **Example: Testing the Live Deployment**

### Test the Live API

**This is a live, working deployment you can test right now** (hosted by the project maintainer):

**PowerShell:**
```powershell
# Set the live demo endpoint
$API_ENDPOINT = "https://uvynvd8xfe.execute-api.eu-north-1.amazonaws.com/dev"

# Test HEAD operation (first n elements)
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'
# Returns: result : {apple, banana, cherry}

# Test TAIL operation (last n elements)
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/tail" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":2}'
# Returns: result : {date, elderberry}

# Test edge case: n larger than list
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{"list":["a","b"],"n":5}'
# Returns: result : {a, b}

# Test error: wrong endpoint (should return 404)
Invoke-RestMethod -Uri "$API_ENDPOINT/v2/list/head" -Method Post -ContentType "application/json" -Body '{"list":["a","b"],"n":2}'
# Returns: 404 Not Found
```

**Unix/Linux/Mac (curl):**
```bash
# Test the live demo endpoint
curl -X POST "https://uvynvd8xfe.execute-api.eu-north-1.amazonaws.com/dev/v1/list/head" \
  -H "Content-Type: application/json" \
  -d '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'
# Expected: {"result":["apple","banana","cherry"]}

curl -X POST "https://uvynvd8xfe.execute-api.eu-north-1.amazonaws.com/dev/v1/list/tail" \
  -H "Content-Type: application/json" \
  -d '{"list":["apple","banana","cherry","date","elderberry"],"n":2}'
# Expected: {"result":["date","elderberry"]}
```

---

## 📖 **Understanding the API**

### **API Operations Explained**

#### **HEAD Operation**
Returns the **first `n` elements** from a list.

**Request:**
```json
{
  "list": ["apple", "banana", "cherry", "date", "elderberry"],
  "n": 3
}
```

**Response:**
```json
{
  "result": ["apple", "banana", "cherry"]
}
```

**How it works**: Like the Unix `head` command, this returns the beginning of the list.

#### **TAIL Operation**
Returns the **last `n` elements** from a list.

**Request:**
```json
{
  "list": ["apple", "banana", "cherry", "date", "elderberry"],
  "n": 2
}
```

**Response:**
```json
{
  "result": ["date", "elderberry"]
}
```

**How it works**: Like the Unix `tail` command, this returns the end of the list.

---

### **Edge Cases and Error Handling**

The API handles all edge cases gracefully:

#### **Case 1: n is larger than list length**
```json
Request: {"list": ["a", "b"], "n": 5}
Response: {"result": ["a", "b"]}
```
Returns the entire list (no error).

#### **Case 2: n is zero**
```json
Request: {"list": ["a", "b", "c"], "n": 0}
Response: {"result": []}
```
Returns an empty list.

#### **Case 3: Empty list**
```json
Request: {"list": [], "n": 5}
Response: {"result": []}
```
Returns an empty list.

#### **Case 4: Negative n**
```json
Request: {"list": ["a", "b"], "n": -1}
Response: HTTP 400 Bad Request
Error: {"error": "n must be non-negative"}
```

#### **Case 5: Missing required fields**
```json
Request: {}
Response: HTTP 400 Bad Request
Error: {"error": "list and n are required"}
```

#### **Case 6: Wrong endpoint**
```
Request: GET /v1/list/head
Response: HTTP 404 Not Found
Error: {"message": "Not Found"}
```
Only POST method is supported.

---

### **Quick Reference: Build Commands**

**Windows (PowerShell):**
```powershell
# Run tests
python -m pytest src/tests/ -v

# Build Lambda package
python scripts/build_zip.py

# Deploy to dev
cd infra
terraform init
terraform plan -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"
terraform apply -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"
```

### Validate Terraform Configuration

Before deploying, validate your infrastructure:

```powershell
cd infra
terraform init
terraform fmt -recursive
terraform validate
# Should output: "Success! The configuration is valid."
```

### Test Your Deployed API
```bash
# Get endpoint
terraform output api_endpoint

# Test (Unix/Mac)
BASE_URL=$(terraform -chdir=infra output -raw api_endpoint) ./scripts/call_head.sh

# Test (Windows - manual curl)
curl -X POST "https://YOUR_API.execute-api.eu-north-1.amazonaws.com/dev/v1/list/head" `
  -H "Content-Type: application/json" `
  -d '{"list":["a","b","c"],"n":2}'
```

---

## ✅ Pre-Deployment Checklist

### Completed ✅
- [x] **Python 3.12+** installed and in PATH
- [x] **Terraform 1.6+** installed and in PATH  
- [x] **pytest** installed (`pip install pytest`)
- [x] **Lambda package built** (`python scripts/build_zip.py`)
- [x] **Tests passing** (15/15 tests pass)
- [x] **Terraform initialized** (`terraform init`)
- [x] **Terraform validated** (`terraform validate` ✅ Success!)
- [x] **AWS CLI** installed and configured (`aws configure`)
- [x] **AWS credentials** configured with IAM user permissions
- [x] **AWS region** set to `eu-north-1`

### 🚀 Ready for Deployment!
All prerequisites are complete. You can now deploy to AWS!

**Quick Deploy Commands:**
```powershell
cd infra

# Step 1: Review what will be created (recommended)
terraform plan -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"

# Step 2: Deploy to AWS (if plan looks good)
terraform apply -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"

# Step 3: Get your API endpoint
terraform output api_endpoint
```

---

## 🎯 Next Steps - Ready to Deploy!

Your infrastructure is **validated and ready**! Here's what to do next:

### 1. Configure AWS Credentials (If Not Done)

#### **Step 1: Create an IAM User with Access Keys**

If you don't have AWS credentials yet, follow these steps:

1. **Log in to the AWS Console**
   - Open https://console.aws.amazon.com/
   - Sign in with your root user

2. **Open the IAM service**
   - In the search bar, type **IAM** and select **IAM (Identity and Access Management)**
   - Go to **Users**
   - Click **Add users**

3. **Create a new user**
   - Enter a username, for example: `terraform-admin`
   - Click **Next**

4. **Assign permissions**
   - Select **Attach policies directly**
   - Search for and select **AdministratorAccess**
   - This gives the user full permissions (the easiest option for development)
   - You can later restrict the permissions more narrowly
   - Click **Next**

5. **Add tags (optional)**
   - You may add tags, for example: `Environment=dev`
   - This step can also be skipped
   - Click **Next**

6. **Create the user**
   - Review the settings in the summary
   - Click **Create user**
   - The user is now created, but without any access keys

7. **Create an Access Key**
   - From the list, click the user you just created
   - On the user's page, open the **Security credentials** tab
   - Scroll down to the **Access keys** section
   - Click **Create access key**
   - For the use case, choose **Command Line Interface (CLI)**
   - Click **Next**, then **Create access key**
   - The **Access Key ID** and **Secret Access Key** will now be displayed
   - ⚠️ **Save them immediately** - you can also download a CSV file
   - ⚠️ **Note**: The Secret Access Key is shown only once

#### **Step 2: Configure AWS CLI**

**Install AWS CLI** (if not already installed):
- Download from: https://aws.amazon.com/cli/
- Or for Windows: https://awscli.amazonaws.com/AWSCLIV2.msi

**Run the configuration command:**
```powershell
aws configure
```

**You will be prompted for 4 values:**

```
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: eu-north-1
Default output format [None]: json
```

- **AWS Access Key ID**: Paste the Access Key ID you saved from Step 1
- **AWS Secret Access Key**: Paste the Secret Access Key you saved from Step 1
- **Default region name**: Enter `eu-north-1` (or your preferred AWS region)
- **Default output format**: Enter `json` (recommended)

> ⚠️ **Important**: These credentials are saved in `~/.aws/credentials` on your computer. Never commit this file to version control!

**Verify your credentials are working:**
```powershell
aws sts get-caller-identity
```

**Expected output:**
```json
{
    "UserId": "AIDAI23HXS2EX4MPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
}
```

If you see your account information, you're ready to deploy! ✅

> **🔒 Security Best Practices:**
> - Never commit AWS credentials to version control
> - Use IAM users instead of root account for day-to-day operations
> - Enable MFA (Multi-Factor Authentication) on your AWS account
> - For production, use more restrictive IAM policies instead of `AdministratorAccess`
> - Rotate access keys regularly
> - Consider using AWS IAM Identity Center (SSO) for team access

### 2. Review Terraform Plan
```powershell
cd infra
terraform plan -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"
# Review the resources that will be created
```

### 3. Deploy to AWS (Dev Environment)
```powershell
terraform apply -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"
# Type "yes" when prompted
```

### 4. Get Your API Endpoint
```powershell
terraform output api_endpoint
# Example output: https://abc123xyz.execute-api.eu-north-1.amazonaws.com/dev
```

### 5. Test Your Live API

**PowerShell:**
```powershell
# Save endpoint to variable
$API_ENDPOINT = terraform output -raw api_endpoint

# Test HEAD operation
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/head" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'

# Test TAIL operation
Invoke-RestMethod -Uri "$API_ENDPOINT/v1/list/tail" -Method Post -ContentType "application/json" -Body '{"list":["apple","banana","cherry","date","elderberry"],"n":2}'
```

**Unix/Linux/Mac:**
```bash
API_ENDPOINT=$(terraform output -raw api_endpoint)

curl -X POST "$API_ENDPOINT/v1/list/head" -H "Content-Type: application/json" -d '{"list":["apple","banana","cherry","date","elderberry"],"n":3}'
```

---

## Security Enhancements (optional, configurable via Terraform vars)

- **JWT (Cognito) authorizer**: set `enable_jwt=true` and provide `jwt_issuer` and `jwt_audience`. Alternatively set `enable_cognito=true` to auto‑create a user pool + client and use outputs `jwt_issuer`/`jwt_audience`.
- **Throttling** (HTTP API v2 Stage): `throttling_burst_limit` (default 50) and `throttling_rate_limit` (default 25 req/s). ✅ **Currently enabled**
- **Alarms**: SNS topic + CloudWatch alarms for API 5XX, API p95 latency, and Lambda errors. Configure `-var "alarm_email=you@example.com"` to subscribe. ✅ **Currently enabled**

### ⚠️ **Important: WAF Limitation with HTTP API v2**

**AWS WAFv2 does NOT support direct association with HTTP API v2 (ApiGatewayV2).**

WAFv2 can only be directly associated with:
- ✅ REST API v1 (`/restapis/{id}/stages/{name}`)
- ✅ Application Load Balancer (ALB)
- ✅ CloudFront distribution
- ✅ AppSync GraphQL API
- ❌ HTTP API v2 (`/apis/{id}/stages/{name}`) - **Not supported**

**To add WAF protection to this project, choose one of these options:**

1. **Switch to REST API v1** - Uncomment `module.rest_api` in `main.tf` (already configured with WAF support)
2. **Add CloudFront** - Put CloudFront in front of HTTP API and attach WAF to CloudFront distribution
3. **Add Application Load Balancer** - Place ALB in front of HTTP API and attach WAF to ALB

For development/testing, HTTP API v2 without WAF is acceptable. For production, consider adding one of the above layers.

**Example plan/apply with JWT via Cognito and alarms:**

**Unix/Linux/Mac:**
```bash
# Build Lambda
make package

cd infra
terraform init
terraform apply -auto-approve \
  -var "lambda_package_path=../build/listservice.zip" \
  -var "enable_cognito=true" \
  -var "enable_jwt=true" \
  -var "jwt_issuer=$(terraform output -raw jwt_issuer)" \
  -var 'jwt_audience=["'$(terraform output -raw jwt_audience | tr -d "[]"")'"]' \
  -var "alarm_email=you@example.com"
```

**Windows (PowerShell):**
```powershell
# Build Lambda
python scripts/build_zip.py

cd infra
terraform init
terraform apply -auto-approve `
  -var "lambda_package_path=../build/listservice.zip" `
  -var "enable_cognito=true" `
  -var "enable_jwt=true" `
  -var "alarm_email=you@example.com"
# Note: On Windows, configure jwt_issuer and jwt_audience outputs after first apply
```


### Optional hardening

**Remote state backend**  
Create S3 bucket + DynamoDB lock table and generate `infra/backend.tf`:
```bash
REGION=eu-north-1 BUCKET=my-tfstate-bucket TABLE=my-tflock ./scripts/init_backend.sh
```

**Seed a Cognito user**
```bash
pip install boto3
python scripts/seed_cognito_user.py \
  --user-pool-id $(terraform -chdir=infra output -raw jwt_issuer | awk -F'/' '{print $NF}') \
  --username demo.user \
  --email demo@example.com \
  --temp-password 'TempPassw0rd!'
```

**WAF allowlist + Bot Control**
Set allowlist and enforce it (blocks all except allowed CIDRs), and enable Bot Control:
```bash
terraform apply -auto-approve \
  -var "lambda_package_path=../build/listservice.zip" \
  -var 'alarm_email=you@example.com' \
  -var 'enable_jwt=true' -var 'jwt_issuer=...' -var 'jwt_audience=["..."]' \
  -var 'waf_allowlist_cidrs=["203.0.113.0/24","198.51.100.10/32"]' \
  -var 'waf_enforce_allowlist=true' \
  -var 'waf_enable_bot_control=true'
```


### Additional hardening & operations

**WAF Logging**  
WAFv2 can be configured to log all inspected requests to CloudWatch Logs, Kinesis Data Firehose, or S3.  
This is recommended in production for forensic analysis.  
Steps:  
1. Enable `aws_wafv2_web_acl_logging_configuration` resource in `modules/waf/main.tf`.  
2. Provide `log_destination_configs` to an existing Kinesis Firehose, S3, or CloudWatch Logs group.  
3. Apply changes with Terraform.  
This enables detailed request/response metadata for security auditing.

**Route-level throttling**  
Stage-level throttling is already configured (`throttling_burst_limit`, `throttling_rate_limit`).  
You can also configure per-route settings in `modules/http_api/main.tf` by extending `route_settings`. Example:  
```hcl
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = var.stage
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }

  route_settings = {
    "POST /v1/list/head" = {
      throttling_burst_limit = 20
      throttling_rate_limit  = 10
    }
    "POST /v1/list/tail" = {
      throttling_burst_limit = 100
      throttling_rate_limit  = 50
    }
  }
}
```

**API Keys and Usage Plan (dev only)**  
If JWT is not enabled (e.g., dev/staging), you can secure the API with API keys:  
- Define `aws_apigatewayv2_api_key` and `aws_apigatewayv2_usage_plan`.  
- Associate the usage plan with routes.  
- Pass key via `x-api-key` header in requests.  
Note: Do not use API keys as the only auth in production.

**Makefile targets**  
Convenience tasks for backend init and Cognito seeding can be added:  
```makefile
backend-init:
	REGION=eu-north-1 BUCKET=my-tfstate-bucket TABLE=my-tflock ./scripts/init_backend.sh

cognito-seed:
	python scripts/seed_cognito_user.py \	  --user-pool-id $(shell terraform -chdir=infra output -raw jwt_issuer | awk -F'/' '{print $$NF}') \	  --username demo.user \	  --email demo@example.com \	  --temp-password 'TempPassw0rd!'
```
These allow you to quickly bootstrap the backend and add test users to Cognito.

---

### Summary of security features (all configurable)
- **JWT Authorizer (Cognito)** for production-grade authn/z.
- **WAFv2** with AWS Managed Rules, allowlist, bot control, and optional logging.
- **Throttling** both at stage and per-route level.
- **CloudWatch alarms** (5xx, latency, Lambda errors) with SNS notifications.
- **X-Ray tracing** for distributed request analysis.
- **Remote state backend** (S3 + DynamoDB) for Terraform state consistency.
- **API Keys** for non-production environments.
- **Cognito seeding** script for quick test user creation.

## Architecture Diagram

![Architecture](architecture.png)


## Architecture (Mermaid)

```mermaid
flowchart LR
  client[Client (curl / Postman / Frontend)]
  waf[WAFv2 \n (AWS Managed Rules, Allowlist, Bot Control)]
  apigw[API Gateway \n HTTP API v2]
  lambda[Lambda \n list_service_handler (Python 3.12)]
  cw[CloudWatch \n Logs + Alarms]
  xray[X-Ray]
  cognito[Cognito \n User Pool / JWT Authorizer]
  sns[SNS \n Notifications]

  client --> waf --> apigw --> lambda
  apigw -. JWT .-> cognito
  lambda --> cw --> sns
  lambda --> xray
```

---

## 🧪 Testing

### Test Coverage
The project includes **15 comprehensive unit tests** covering:

- ✅ **Core operations**: `head` and `tail` with various parameters
- ✅ **Default parameters**: Testing default `n=1` behavior
- ✅ **Edge cases**: Empty lists, single items, n > list length
- ✅ **Validation**: All error scenarios (invalid types, bounds, missing fields)
- ✅ **HTTP methods**: Rejecting non-POST requests (405)
- ✅ **Invalid paths**: Unknown endpoints (404)
- ✅ **Malformed JSON**: Invalid request body handling
- ✅ **Performance**: Testing with 1000-item lists
- ✅ **Case handling**: Case-insensitive path matching

### Running Tests

**Quick test run:**
```bash
# Unix/Linux/Mac
make test

# Windows
python -m pytest src/tests/ -q
```

**Verbose output:**
```bash
python -m pytest src/tests/ -v
```

**With coverage report:**
```bash
python -m pytest src/tests/ --cov=src --cov-report=html
# Open htmlcov/index.html
```

All tests pass in **< 0.1s** ⚡

---

## API Documentation & Clients

- **OpenAPI 3.0**: `openapi.yaml` (import into Swagger UI/Insomnia/Postman)
- **Postman**: `postman_collection.json`
  - Set `BASE_URL` to Terraform output `api_endpoint`
  - If using API Keys, enable header and set `API_KEY`

## Public vs Protected Routes (JWT)
You can mark routes as public (no JWT) via Terraform var `public_routes`:
```hcl
module "http_api" {
  source            = "./modules/http_api"
  project_name      = var.project_name
  stage             = var.stage
  lambda_invoke_arn = module.lambda.invoke_arn
  function_name     = module.lambda.function_name

  enable_jwt   = true
  jwt_issuer   = var.jwt_issuer
  jwt_audience = var.jwt_audience

  public_routes = ["POST /v1/list/head"] # head is public, tail requires JWT
}
```

## GitHub Actions: Deploy Pipeline
- Workflow: `.github/workflows/deploy.yml`
- Trigger: **Run workflow** (workflow_dispatch) → choose `dev|stage|prod`
- Job `plan`: builds & tests Lambda, runs `terraform plan`, uploads artifacts
- Job `apply`: manual approval via protected environment, then runs `terraform apply`



### API Key authorizer (Lambda) for dev
HTTP API v2 does not support Usage Plans like REST API v1. For dev/staging we include a **Lambda REQUEST authorizer** that checks `x-api-key` against a configured value.
Enable with:

```hcl
module "auth" {
  source           = "./modules/lambda_authorizer"
  project_name     = var.project_name
  stage            = var.stage
  expected_api_key = var.expected_api_key  # provide via tfvars or env var
}

module "http_api" {
  # ...
  enable_apikey_authorizer = true
  authorizer_lambda_arn    = module.auth.authorizer_arn
}
```

Then call the API with header `x-api-key: <value>`.



## Docs (OpenAPI -> HTML)
- Static docs are available in `docs/index.html` and render `openapi.yaml` via Redoc.
- Serve locally (to avoid CORS issues): `python -m http.server -d docs 8080` then open http://localhost:8080/

## Example curl scripts
- `scripts/call_head.sh` and `scripts/call_tail.sh`
- Usage examples:
```bash
# No auth (dev)
BASE_URL=$(terraform -chdir=infra output -raw api_endpoint) scripts/call_head.sh

# With API key authorizer (dev/stage)
AUTH_HEADER="x-api-key: mydevkey" BASE_URL=$(terraform -chdir=infra output -raw api_endpoint) scripts/call_tail.sh

# With JWT (prod)
AUTH_HEADER="Authorization: Bearer $JWT" BASE_URL=$(terraform -chdir=infra output -raw api_endpoint) scripts/call_head.sh
```


## OpenAPI: single-file HTML
- `docs/openapi_standalone.html` embeds the OpenAPI spec and Redoc in **one file** (no external spec fetch needed). Open locally in your browser.

## REST API v1 (API Keys + Usage Plans)
If you prefer classic REST API features (Usage Plans, per-method API Keys), use the provided module:
```hcl
module "rest_api" {
  source         = "./modules/rest_api"
  project_name   = var.project_name
  stage          = var.stage
  lambda_arn     = module.lambda.invoke_arn
  function_name  = module.lambda.function_name
  # api_key_value = "my-dev-key" # optional; random is used if omitted
}
```

Outputs:
- `rest_invoke_url` – base URL (e.g., `https://<id>.execute-api.<region>.amazonaws.com/dev`)
- `api_key_value` – the generated or provided API key

Call with:
```bash
ENDPOINT=$(terraform -chdir=infra output -raw rest_api_endpoint || echo "")
curl -s -X POST "$ENDPOINT/v1/list/head" -H "Content-Type: application/json" -H "x-api-key: $(terraform -chdir=infra output -raw api_key_value)" -d '{"list":["a","b","c"],"n":2}'
```



## Environment tfvars
Predefined variable files for environments:
- `infra/env/dev.tfvars`
- `infra/env/stage.tfvars`
- `infra/env/prod.tfvars`

Use them with Terraform:
```bash
terraform plan  -var-file="env/dev.tfvars"   -var "lambda_package_path=../build/listservice.zip"
terraform apply -var-file="env/dev.tfvars"   -var "lambda_package_path=../build/listservice.zip"
```

## REST API v1: WAF & per-method throttling
- Module now exposes `stage_arn` for WAF association (via root `modules/waf`).  
- Per-method throttling via variables `head_burst_limit`, `head_rate_limit`, `tail_burst_limit`, `tail_rate_limit`.

## GitHub Actions: matrix deploy
`deploy.yml` runs a plan/apply for a matrix of environments **[dev, stage, prod]** and passes the correct `tfvars` automatically.



## Professional defaults & workflows

- **PR safety checks:** `pr-plan.yml` runs tests, builds the Lambda artifact, executes a Terraform plan (dev tfvars) and posts the plan as a **PR comment**. This gives reviewers full visibility before merging.
- **Environment deployments:** `deploy.yml` uses a **matrix** across `dev|stage|prod` and passes the correct `tfvars` per environment.
- **WAF integration:**
  - **HTTP API v2:** WAF module is associated to the stage via its ARN (module output).
  - **REST API v1:** the module can now **associate a WebACL internally** by setting `enable_waf=true` and `waf_web_acl_arn="arn:aws:wafv2:..."`.
  - **Logging:** WAF module supports optional logging via `enable_logging` + `log_destination_arns` (Kinesis Data Firehose / CloudWatch Logs where supported).
- **Per-route / per-method throttling:** HTTP API v2 supports stage/route throttling; REST API v1 supports **method-specific throttling** via variables (fine-grained rate control).

### Example: REST API v1 with WAF + logging
```hcl
module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
  stage        = var.stage

  # Optional logging
  enable_logging       = true
  log_destination_arns = ["arn:aws:logs:eu-north-1:123456789012:log-group:/aws/waf/listservice:*"]
}

module "rest_api" {
  source         = "./modules/rest_api"
  project_name   = var.project_name
  stage          = var.stage
  lambda_arn     = module.lambda.invoke_arn
  function_name  = module.lambda.function_name

  # Per-method throttling
  head_burst_limit = 20
  head_rate_limit  = 10
  tail_burst_limit = 100
  tail_rate_limit  = 50

  # Associate WAF to REST stage
  enable_waf      = true
  waf_web_acl_arn = module.waf.web_acl_arn
}
```

### Example: PR Plan
- On every pull request, CI will comment the current **Terraform plan** (using `env/dev.tfvars`) to ensure changes are reviewed safely.

---

## 📁 Project Structure

```
listservice/
├── .github/
│   └── workflows/
│       ├── ci.yml           # CI tests & validation
│       ├── deploy.yml       # Multi-env deployment
│       ├── pr-plan.yml      # PR plan comments
│       └── smoke.yml        # Post-deploy smoke tests
├── docs/
│   ├── index.html          # Redoc API documentation
│   └── openapi_standalone.html
├── infra/                   # Terraform infrastructure
│   ├── modules/
│   │   ├── alarms/         # CloudWatch alarms
│   │   ├── http_api/       # API Gateway HTTP API v2
│   │   ├── lambda/         # Lambda function
│   │   ├── lambda_authorizer/ # Custom API key authorizer
│   │   ├── rest_api/       # REST API v1 (optional)
│   │   └── waf/            # WAF v2 with managed rules
│   ├── env/
│   │   ├── dev.tfvars      # Dev environment config
│   │   ├── stage.tfvars    # Stage environment config
│   │   └── prod.tfvars     # Prod environment config
│   ├── main.tf             # Root module
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── providers.tf        # AWS provider config
│   ├── versions.tf         # Terraform version constraints
│   └── cognito.tf          # Optional Cognito user pool
├── scripts/
│   ├── build_zip.py        # Lambda package builder
│   ├── call_head.sh        # Test head endpoint
│   ├── call_tail.sh        # Test tail endpoint
│   ├── init_backend.sh     # S3 backend setup
│   └── seed_cognito_user.py # Cognito user seeding
├── src/
│   ├── handler.py          # Lambda handler (main logic)
│   ├── requirements.txt    # Python dependencies (empty for now)
│   └── tests/
│       └── test_handler.py # Unit tests (15 tests)
├── .gitignore              # Git exclusions
├── LICENSE                 # MIT License
├── Makefile                # Build automation (Unix/Mac)
├── openapi.yaml            # OpenAPI 3.0 specification
├── postman_collection.json # Postman tests
└── README.md               # This file
```

---

## 🔧 Recent Improvements

### 🎉 Successfully Deployed to AWS! (✅ LIVE)
**Infrastructure is deployed and API is responding to requests**

- ✅ **Deployment Date**: October 2, 2025
- ✅ **API Endpoint**: `https://uvynvd8xfe.execute-api.eu-north-1.amazonaws.com/dev`
- ✅ **Lambda Function**: `listservice-dev-handler`
- ✅ **Region**: `eu-north-1` (Stockholm)
- ⚠️ **WAF**: Disabled (discovered AWS limitation - HTTP API v2 not supported by WAFv2)

### Terraform Infrastructure Fixes (✅ ALL FIXED)
**All 17 syntax errors fixed and validated with `terraform validate`**

#### Module Fixes (14)
- ✅ **HTTP API module**: Fixed duplicate route definitions for `/head` and `/tail`
- ✅ **HTTP API module**: Fixed duplicate outputs (removed from main.tf)
- ✅ **HTTP API module**: Fixed variable syntax (comma → equals)
- ✅ **HTTP API module**: Fixed description syntax (escaped quotes)
- ✅ **Lambda module**: Fixed duplicate outputs (removed from main.tf)
- ✅ **Lambda module**: Fixed variable syntax
- ✅ **WAF module**: Fixed invalid HCL syntax (converted to dynamic blocks)
- ✅ **WAF module**: Fixed `override_action` and `action` block syntax (multi-line)
- ✅ **WAF module**: Commented out logging configuration (requires destination ARNs)
- ✅ **Alarms module**: Fixed variable syntax
- ✅ **Cognito module**: Fixed variable syntax errors (comma → equals)
- ✅ **REST API module**: Fixed main.tf output (invalid string manipulation)
- ✅ **REST API module**: Fixed all variable syntax (9 variables)
- ✅ **REST API module**: Added missing `waf_web_acl_arn` variable

#### Root Module Fixes (3)
- ✅ **outputs.tf**: Commented out REST API outputs (module not enabled by default)
- ✅ **Deploy workflow**: Fixed duplicate configuration blocks
- ✅ **Deploy workflow**: Added matrix strategy to apply job

**Status**: `terraform validate` ✅ **Success! The configuration is valid.**

### Testing & Quality
- ✅ Expanded test coverage from 3 to 15 comprehensive tests
- ✅ All 15 tests passing in < 0.1s
- ✅ Coverage: edge cases, validation, HTTP methods, large lists, etc.

### Project Files
- ✅ Added `.gitignore` for Python, Terraform, and build artifacts
- ✅ Added MIT `LICENSE` file
- ✅ Updated `requirements.txt` with helpful comments

### Documentation & Developer Experience
- ✅ Added Windows PowerShell command equivalents throughout
- ✅ Added Terraform validation section to Quick Start
- ✅ Added project structure diagram
- ✅ Added comprehensive test coverage documentation
- ✅ Made WAF Bot Control rule properly conditional
- ✅ Made WAF IP allowlist rule conditional (only when CIDRs provided)

---

## 🔍 Troubleshooting

### Terraform Validation Errors

**"terraform: command not found"**
- Install Terraform from https://www.terraform.io/downloads
- Add to PATH: `C:\terraform\`
- Restart PowerShell

**"No module call named 'rest_api'"**
- Fixed: REST API outputs are now commented out in `outputs.tf`
- REST API module is optional and disabled by default

**"Not enough list items" (WAF logging)**
- Fixed: WAF logging configuration is now commented out
- To enable: uncomment in `modules/waf/main.tf` and provide `log_destination_arns`

### Test Failures

**"pytest: No module named"**
```powershell
pip install pytest
```

**Import errors in tests**
- Ensure you're running from project root: `python -m pytest src/tests/`

### Build Issues

**"Permission denied" on scripts**
```powershell
# Windows: No chmod needed, just run directly
python scripts/build_zip.py
```

### AWS Deployment Issues

**"Error: No valid credential sources found"**

This means Terraform cannot find AWS credentials. Solutions:

1. **If you don't have an IAM user yet:**
   - See the detailed guide in [Step 1: Create an IAM User with Access Keys](#step-1-create-an-iam-user-with-access-keys)
   - This will walk you through creating a user in the AWS Console

2. **If you have credentials but haven't configured them:**
   ```powershell
   aws configure
   # Enter: AWS Access Key ID, Secret Access Key, Region (eu-north-1)
   ```

3. **Alternative - Use environment variables:**
   ```powershell
   $env:AWS_ACCESS_KEY_ID="your-access-key-id"
   $env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
   $env:AWS_DEFAULT_REGION="eu-north-1"
   ```

**"AccessDenied" errors**
- Ensure your IAM user has the necessary permissions:
  - **Lambda** (CreateFunction, UpdateFunctionCode, etc.)
  - **API Gateway** (CreateApi, CreateStage, etc.)
  - **CloudWatch** (CreateLogGroup, PutMetricAlarm, etc.)
  - **WAF** (CreateWebACL, AssociateWebACL, etc.)
  - **IAM** (CreateRole, AttachRolePolicy, etc.)
  - **SNS** (CreateTopic, Subscribe, etc.)
- For development: Use `AdministratorAccess` policy (simplest)
- For production: Use least-privilege custom policies

**"WAFInvalidParameterException: The ARN isn't valid"**

This error occurs when trying to associate WAF with HTTP API v2:
```
Error: WAFInvalidParameterException: INVALID_PARAMETER_VALUE, 
parameter: arn:aws:apigateway:eu-north-1::/apis/{id}/stages/{name}
```

**Root Cause**: AWS WAFv2 does NOT support direct association with HTTP API v2 (ApiGatewayV2).

**Solution**: The WAF module is now commented out in `main.tf`. To add WAF protection:
1. **Switch to REST API v1**: Uncomment `module.rest_api` in `main.tf`
2. **Add CloudFront**: Put CloudFront in front of HTTP API and attach WAF to CloudFront
3. **Add ALB**: Place Application Load Balancer in front and attach WAF to ALB

See the [Security Enhancements](#️-important-waf-limitation-with-http-api-v2) section for details.

**Need to destroy infrastructure?**
```powershell
cd infra
terraform destroy -var-file="env/dev.tfvars" -var "lambda_package_path=../build/listservice.zip"
```

**Terraform state is locked**
```powershell
# If terraform commands hang or show "acquiring state lock"
# This may happen if a previous operation was interrupted
# Force unlock (use the Lock ID from the error message):
terraform force-unlock <LOCK_ID>
```

---

## 💰 AWS Cost Estimate

Understanding the costs of running this infrastructure:

### **Free Tier Eligible** (First 12 months)
- **Lambda**: 1M free requests/month + 400,000 GB-seconds compute
- **API Gateway**: 1M free API calls/month
- **CloudWatch Logs**: 5GB free ingestion
- **CloudWatch Alarms**: 10 alarms free

### **Estimated Monthly Costs** (After Free Tier)
For low-traffic development/testing (1000 requests/day):

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 30K requests, 128MB, 100ms avg | ~$0.01 |
| API Gateway | 30K requests | ~$0.03 |
| CloudWatch Logs | ~100MB logs | ~$0.05 |
| CloudWatch Alarms | 3 alarms | ~$0.30 |
| ~~WAF~~ | ~~WebACL + Rules~~ | ~~$5.00~~ **Disabled** |
| **Total** | | **~$0.40/month** ✅ |

> **✅ Current deployment**: WAF is disabled, so costs are minimal (~$0.40/month)

### **Cost Optimization Tips**
- ✅ **WAF disabled**: Saves ~$5/month (HTTP API v2 doesn't support direct WAF association)
- 🔧 **Reduce CloudWatch retention**: Change log retention to 1 day for dev
- 🔧 **Use `terraform destroy`** when not actively developing
- 🔧 **Monitor costs**: Set up AWS Budget alerts in the AWS Console

### **Production Costs**
For production with 1M requests/month:
- Estimated: **$20-50/month** depending on:
  - Lambda execution time
  - CloudWatch log retention
  - WAF request volume
  - Cognito active users (if enabled)

> **💡 Tip**: Always run `terraform destroy` after testing to avoid charges!

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Run tests: `make test` (Unix) or `python -m pytest src/tests/ -v` (Windows)
4. Submit a pull request (PR plan will run automatically)

---

## 📧 Support

For issues, questions, or feature requests, please open a GitHub issue.
