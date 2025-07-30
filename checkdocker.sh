# 1. Check what's actually in your Dockerfile
echo "=== DOCKERFILE CONTENT ==="
cat Dockerfile

# 2. Check if there are multiple Dockerfiles
echo "=== ALL DOCKERFILES IN PROJECT ==="
find . -name "Dockerfile" -type f

# 3. Check git status
echo "=== GIT STATUS ==="
git status

# 4. Check what's been committed
echo "=== LAST COMMIT DETAILS ==="
git show --stat HEAD

# 5. Check remote status
echo "=== REMOTE SYNC STATUS ==="
git log --oneline -5
git status -uno
