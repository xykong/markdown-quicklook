#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_DIR="$PROJECT_ROOT/.sparkle-keys"
PUBLIC_KEY_FILE="$KEYS_DIR/sparkle_public_key.txt"
PRIVATE_KEY_FILE="$KEYS_DIR/sparkle_private_key.pem"

echo "🔐 Sparkle Key Generator"
echo "======================="
echo ""

if [ -f "$PUBLIC_KEY_FILE" ] && [ -f "$PRIVATE_KEY_FILE" ]; then
    echo "⚠️  Keys already exist in $KEYS_DIR"
    echo ""
    echo "Public key:  $PUBLIC_KEY_FILE"
    echo "Private key: $PRIVATE_KEY_FILE"
    echo ""
    read -p "Do you want to regenerate? This will REPLACE existing keys! (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled. Using existing keys."
        exit 0
    fi
    echo ""
fi

mkdir -p "$KEYS_DIR"

echo "📝 Generating new EdDSA key pair..."
echo ""

openssl genpkey -algorithm ed25519 -out "$PRIVATE_KEY_FILE"

openssl pkey -in "$PRIVATE_KEY_FILE" -pubout -outform DER | tail -c 32 | base64 > "$PUBLIC_KEY_FILE"

chmod 600 "$PRIVATE_KEY_FILE"
chmod 644 "$PUBLIC_KEY_FILE"

PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")

echo "✅ Keys generated successfully!"
echo ""
echo "📁 Location: $KEYS_DIR/"
echo ""
echo "🔑 Public Key (add to Info.plist):"
echo "   $PUBLIC_KEY"
echo ""
echo "🔒 Private Key (keep secret!):"
echo "   $PRIVATE_KEY_FILE"
echo ""
echo "⚠️  IMPORTANT:"
echo "   1. Add the public key to Sources/Markdown/Info.plist:"
echo "      Replace 'SPARKLE_PUBLIC_KEY_PLACEHOLDER' with the key above"
echo ""
echo "   2. Keep the private key SECRET!"
echo "      - Never commit it to git"
echo "      - Store it in a secure location"
echo "      - Use it only for signing releases"
echo ""
echo "   3. The .sparkle-keys/ directory is already in .gitignore"
echo ""

cat > "$KEYS_DIR/README.md" <<EOF
# Sparkle Keys

Generated on: $(date)

## Files

- \`sparkle_public_key.txt\` - Public key for verifying updates (safe to share)
- \`sparkle_private_key.pem\` - Private key for signing updates (KEEP SECRET!)

## Usage

### Public Key
Add to \`Sources/Markdown/Info.plist\`:

\`\`\`xml
<key>SUPublicEDKey</key>
<string>$(cat "$PUBLIC_KEY_FILE")</string>
\`\`\`

### Private Key
Use with \`sign_update\` tool when releasing:

\`\`\`bash
./sign_update build/FluxMarkdown.dmg .sparkle-keys/sparkle_private_key.pem
\`\`\`

## Security

⚠️ **NEVER commit the private key to version control!**

The \`.sparkle-keys/\` directory is in \`.gitignore\`.

## Backup

Store the private key in a secure location:
- Password manager
- Encrypted backup
- Secure key management service
EOF

if ! grep -q "^\.sparkle-keys/" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    echo ".sparkle-keys/" >> "$PROJECT_ROOT/.gitignore"
    echo "📝 Added .sparkle-keys/ to .gitignore"
fi

echo "✨ Done! Next steps:"
echo "   1. Update Info.plist with the public key"
echo "   2. Run 'make generate' to regenerate Xcode project"
echo "   3. Build and test the app"
echo ""
