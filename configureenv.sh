# Configure your API keys
echo "🔑 Configuring environment..."
echo "Please add your OpenAI API key to .env file:"
echo "OPENAI_API_KEY=sk-your-actual-key-here"
echo ""
echo "Press Enter after editing .env file..."
read

# Verify configuration
if grep -q "sk-" .env; then
    echo "✅ API key found in .env"
else
    echo "⚠️ Please add your OpenAI API key to .env file"
fi
