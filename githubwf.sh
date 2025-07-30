git add .github/workflows/aws-deploy.yml

# Add your application files
git add Dockerfile
git add tentacles/
git add tests/
git add dashboard/

# Add configuration files
git add requirements.txt  # if you created it
git add .gitignore       # if you created it

# Check what's being added
git status

# Commit everything
git commit -m "Add multi-service AWS deployment workflow

- Added GitHub Actions workflow for both main app and dashboard
- Main Python application (tentacles, tests)
- Dashboard Node.js service
- Updated workflow to handle ECR repositories for both services"

# Push to GitHub
git push origin master
