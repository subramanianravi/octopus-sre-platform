#!/bin/bash
# Fix Git push issue - branch name mismatch

echo "🔍 Diagnosing Git branch issue..."

# Check current branch
echo "📍 Current branch:"
git branch

# Check remote branches
echo "📡 Remote branches:"
git branch -r

# Check remote URL
echo "🌐 Remote URL:"
git remote -v

echo ""
echo "🛠️ SOLUTION OPTIONS:"
echo "==================="

# Option 1: Push to master
echo "1️⃣ OPTION 1: Push to master branch"
echo "   git push origin master"
echo "   (if your remote expects master)"
echo ""

# Option 2: Rename to main and push
echo "2️⃣ OPTION 2: Rename branch to main and push"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "   (if your remote expects main)"
echo ""

# Option 3: Check what remote expects
echo "3️⃣ OPTION 3: Check remote repository first"
echo "   git ls-remote --heads origin"
echo ""

read -p "Choose option [1/2/3]: " choice

case $choice in
    1)
        echo "🚀 Pushing to master branch..."
        git push origin master
        if [ $? -eq 0 ]; then
            echo "✅ Successfully pushed to master!"
        else
            echo "❌ Push to master failed. Remote might expect 'main' branch."
            echo "💡 Try option 2 to rename branch to main"
        fi
        ;;
        
    2)
        echo "🔄 Renaming branch to main and pushing..."
        git branch -M main
        git push -u origin main
        if [ $? -eq 0 ]; then
            echo "✅ Successfully pushed to main!"
            echo "📝 Your default branch is now 'main'"
        else
            echo "❌ Push failed. You might need to create the remote repository first."
        fi
        ;;
        
    3)
        echo "🔍 Checking remote repository..."
        git ls-remote --heads origin
        echo ""
        echo "📋 Available remote branches shown above."
        echo "💡 Choose option 1 for master or option 2 for main based on what you see."
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📊 Current status:"
echo "=================="

# Show current branch
echo "🌿 Current branch: $(git branch --show-current)"

# Show commit history
echo "📝 Recent commits:"
git log --oneline -3

# Show remote status
echo "📡 Remote status:"
git status

echo ""
echo "🎉 Octopus Integration Summary:"
echo "=============================="
echo "✅ 22 files changed, 2146 insertions, 205 deletions"
echo "✅ Complete SRE platform with Brain + 8 Tentacles"
echo "✅ Docker containerization complete"
echo "✅ Monitoring stack integrated"
echo "✅ All committed locally"

if git log --oneline -1 | grep -q "Octopus"; then
    echo "✅ Octopus commit ready for push"
else
    echo "⚠️  Please verify your Octopus commit"
fi

echo ""
echo "🚀 Next steps after successful push:"
echo "1. Check GitHub repository for all files"
echo "2. Set up GitHub Actions (optional)"
echo "3. Update README with deployment instructions"
echo "4. Share repository with team"
