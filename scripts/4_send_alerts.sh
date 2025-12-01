#!/bin/bash
# scripts/4_send_alerts.sh

# 1. Load Config & Secrets
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"
source "$SCRIPT_DIR/../config/secrets.sh"

INPUT_CSV="$DATA_DIR/$FILE_DELAYS"
REPORT_PDF="$REPORT_DIR/report_$(date +%Y-%m-%d).pdf"

# Check for Major Delays
CRITICAL_COUNT=$(grep -c "MAJOR_DELAY" "$INPUT_CSV")

if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo "⚠️  Major delays detected ($CRITICAL_COUNT). Sending email..."

    BODY="Critical Alert: Public Transport Tracker\n\n"
    BODY+="We detected $CRITICAL_COUNT bus(es) with major delays.\n"
    BODY+="Please find the detailed PDF report attached."

    # Strip spaces from App Password for URL safety
    CLEAN_PASS=$(echo "$EMAIL_PASS" | tr -d ' ')
    
    # URL Encode the '@' in the username (replace @ with %40)
    # This is required because we are putting the email inside the URL
    ENCODED_USER="${EMAIL_USER//@/%40}"

    # Modern v15 Syntax (Silent & Future-proof)
    echo -e "$BODY" | mailx \
        -s "🚨 Transit Alert: $CRITICAL_COUNT Major Delays" \
        -S v15-compat=yes \
        -S mta="smtp://$ENCODED_USER:$CLEAN_PASS@smtp.gmail.com:587" \
        -S smtp-auth=login \
        -S smtp-use-starttls \
        -S ssl-verify=ignore \
        -S from="Bus Tracker <$EMAIL_USER>" \
        -a "$REPORT_PDF" \
        "$ALERT_RECIPIENT" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Email sent successfully to $ALERT_RECIPIENT"
    else
        echo "❌ Error sending email. Check your connection."
    fi
else
    echo "✅ No critical delays. No email sent."
fi