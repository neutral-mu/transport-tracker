#!/bin/bash
# setup_wizard.sh

# --- HARDCODED CREDENTIALS (DEV ONLY) ---
# REPLACE THIS with the actual Gmail address you just created:
SENDER_EMAIL="neutral.mu@gmail.com"
SENDER_PASS="uxtk rzts hetj lwwh"
# ----------------------------------------

echo "=========================================="
echo "🔧 Public Transport Tracker - Demo Setup"
echo "=========================================="
echo "The system is pre-configured to send alerts from: $SENDER_EMAIL"
echo ""

# Ask user for recipient
read -p "Where should we send the reports? (Enter Email): " RECIPIENT_EMAIL

# Save to config/secrets.sh
mkdir -p config
SECRETS_FILE="config/secrets.sh"

cat <<SECRET > "$SECRETS_FILE"
#!/bin/bash
export EMAIL_USER="$SENDER_EMAIL"
export EMAIL_PASS="$SENDER_PASS"
export SMTP_URL="smtp://smtp.gmail.com:587"
export ALERT_RECIPIENT="$RECIPIENT_EMAIL"
SECRET

chmod 600 "$SECRETS_FILE"

echo "=========================================="
echo "✅ Setup Complete!"
echo "   Alerts will be sent to: $RECIPIENT_EMAIL"
echo "=========================================="