#!/bin/bash
# ==============================================
# 🐙 Octopus SRE Platform - AWS Setup Scripts
# ==============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}$(echo $1 | sed 's/./-/g')${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ==============================================
# 🏗️ MAIN SETUP SCRIPT
# ==============================================
setup_aws_deployment() {
    print_header "🐙 Octopus SRE Platform - AWS Setup"
    
    # Get user input
    read -p "🌍 Environment (development/staging/production): " ENVIRONMENT
    ENVIRONMENT=${ENVIRONMENT:-development}
    
    read -p "🌐 AWS Region (us-east-1): " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
    
    read -p "🐙 Number of Tentacles (8): " TENTACLE_COUNT
    TENTACLE_COUNT=${TENTACLE_COUNT:-8}
    
    read -p "🐳 Deployment Type (ecs/eks): " DEPLOYMENT_TYPE
    DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-ecs}
    
    echo ""
    print_info "Configuration:"
    print_info "Environment: $ENVIRONMENT"
    print_info "Region: $AWS_REGION"
    print_info "Tentacles: $TENTACLE_COUNT"
    print_info "Type: $DEPLOYMENT_TYPE"
    echo ""
    
    read -p "Continue with setup? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    
    # Run setup steps
    setup_aws_cli
    setup_ecr_repositories
    setup_secrets_manager
    create_basic_infrastructure
    
    print_success "AWS setup complete!"
    show_next_steps
}

# ==============================================
# ⚙️ AWS CLI SETUP
# ==============================================
setup_aws_cli() {
    print_header "⚙️ AWS CLI Setup"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Please install it first:"
        print_info "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Run 'aws configure'"
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_success "AWS CLI configured. Account ID: $ACCOUNT_ID"
}

# ==============================================
# 🐳 ECR REPOSITORIES SETUP
# ==============================================
setup_ecr_repositories() {
    print_header "🐳 Setting up ECR Repositories"
    
    REPOSITORIES=("octopus/brain" "octopus/tentacle" "octopus/dashboard")
    
    for REPO in "${REPOSITORIES[@]}"; do
        echo "Creating ECR repository: $REPO"
        
        aws ecr create-repository \
            --repository-name $REPO \
            --region $AWS_REGION \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256 \
            2>/dev/null || print_warning "Repository $REPO might already exist"
    done
    
    print_success "ECR repositories created"
}

# ==============================================
# 🔐 SECRETS MANAGER SETUP
# ==============================================
setup_secrets_manager() {
    print_header "🔐 Setting up AWS Parameter Store"
    
    read -p "🔑 OpenAI API Key: " -s OPENAI_KEY
    echo
    read -p "🤖 Anthropic API Key (optional): " -s ANTHROPIC_KEY
    echo
    
    # Store secrets in Parameter Store
    echo "Storing secrets in Parameter Store..."
    
    aws ssm put-parameter \
        --name "/$ENVIRONMENT/octopus/openai-api-key" \
        --value "$OPENAI_KEY" \
        --type "SecureString" \
        --overwrite \
        --region $AWS_REGION > /dev/null
    
    if [ ! -z "$ANTHROPIC_KEY" ]; then
        aws ssm put-parameter \
            --name "/$ENVIRONMENT/octopus/anthropic-api-key" \
            --value "$ANTHROPIC_KEY" \
            --type "SecureString" \
            --overwrite \
            --region $AWS_REGION > /dev/null
    fi
    
    print_success "Secrets stored in Parameter Store"
}

# ==============================================
# 🏗️ CREATE BASIC INFRASTRUCTURE
# ==============================================
create_basic_infrastructure() {
    print_header "🏗️ Creating Basic Infrastructure"
    
    # Create VPC (simplified version)
    print_info "This setup creates basic ECR repositories and stores secrets."
    print_info "For full infrastructure deployment, you'll need the CloudFormation template."
    print_warning "Complete infrastructure setup requires the full CloudFormation template from the artifacts."
}

# ==============================================
# 📋 SHOW NEXT STEPS
# ==============================================
show_next_steps() {
    print_header "📋 Next Steps"
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    echo ""
    print_success "🎉 Basic AWS setup complete!"
    echo ""
    print_info "✅ What was created:"
    echo "  🐳 ECR repositories for container images"
    echo "  🔐 API keys stored in Parameter Store"
    echo "  ⚙️ AWS CLI configured and verified"
    echo ""
    
    print_info "🔑 Add these GitHub Secrets:"
    echo "AWS_ACCESS_KEY_ID=[your-aws-access-key]"
    echo "AWS_SECRET_ACCESS_KEY=[your-aws-secret-key]"
    echo "AWS_ACCOUNT_ID=$ACCOUNT_ID"
    echo ""
    
    print_info "🚀 Deploy via GitHub Actions:"
    echo "1. Commit your code: git add . && git commit -m 'Add AWS deployment'"
    echo "2. Push to GitHub: git push origin main"
    echo "3. Go to Actions tab → 'AWS Deployment Pipeline' → 'Run workflow'"
    echo ""
    
    print_info "🐳 Or deploy locally with Docker Compose:"
    echo "1. Update .env with your API keys"
    echo "2. Run: make deploy"
}

# ==============================================
# 🏥 HEALTH CHECK
# ==============================================
health_check() {
    print_header "🏥 Basic Health Check"
    
    # Check AWS connectivity
    if aws sts get-caller-identity &> /dev/null; then
        print_success "AWS connection working"
    else
        print_error "AWS connection failed"
    fi
    
    # Check ECR repositories
    REPOSITORIES=("octopus/brain" "octopus/tentacle" "octopus/dashboard")
    for REPO in "${REPOSITORIES[@]}"; do
        if aws ecr describe-repositories --repository-names $REPO --region $AWS_REGION &> /dev/null; then
            print_success "ECR repository exists: $REPO"
        else
            print_error "ECR repository missing: $REPO"
        fi
    done
}

# ==============================================
# 🚀 MAIN EXECUTION
# ==============================================
case "${1:-setup}" in
    "setup"|"deploy")
        setup_aws_deployment
        ;;
    "health")
        health_check
        ;;
    *)
        echo "Usage: $0 {setup|health}"
        echo ""
        echo "Commands:"
        echo "  setup     - Complete AWS setup"
        echo "  health    - Check AWS setup"
        exit 1
        ;;
esac
