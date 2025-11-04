#!/usr/bin/env python3
"""
Discord Webhook Converter for AlertManager
Converts AlertManager webhook format to Discord webhook format
"""

import json
import requests
import sys
from flask import Flask, request, jsonify

app = Flask(__name__)

# Discord webhook URL
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1427356501097447586/b_mvRx5MFh6VlLDSfvv90c70Mrr6PPWVJmERhzic3ms3jc9wccch4KrWaMG9GB5hW4e2"

def format_discord_message(alert_data):
    """Convert AlertManager webhook data to Discord embed format"""
    
    # Get alert information
    alerts = alert_data.get('alerts', [])
    if not alerts:
        return None
    
    # Use first alert for main info
    alert = alerts[0]
    labels = alert.get('labels', {})
    annotations = alert.get('annotations', {})
    
    # Determine color based on severity
    severity = labels.get('severity', 'warning')
    color_map = {
        'critical': 0xFF0000,  # Red
        'warning': 0xFFA500,   # Orange
        'info': 0x00FF00       # Green
    }
    color = color_map.get(severity, 0xFFA500)
    
    # Create Discord embed
    embed = {
        "title": f"🚨 Oracle Database Alert: {labels.get('alertname', 'Unknown')}",
        "color": color,
        "fields": [
            {
                "name": "Status",
                "value": alert.get('status', 'Unknown'),
                "inline": True
            },
            {
                "name": "Severity", 
                "value": severity.upper(),
                "inline": True
            },
            {
                "name": "Instance",
                "value": labels.get('instance', 'Unknown'),
                "inline": True
            }
        ],
        "timestamp": alert.get('startsAt', ''),
        "footer": {
            "text": "Oracle Database Monitoring"
        }
    }
    
    # Add description if available
    if 'description' in annotations:
        embed["description"] = annotations['description']
    
    # Add summary if available
    if 'summary' in annotations:
        embed["fields"].append({
            "name": "Summary",
            "value": annotations['summary'],
            "inline": False
        })
    
    # Add value if available
    if 'value' in alert:
        embed["fields"].append({
            "name": "Value",
            "value": str(alert['value']),
            "inline": True
        })
    
    return {
        "embeds": [embed]
    }

@app.route('/', methods=['POST'])
def webhook():
    """Handle incoming webhook from AlertManager"""
    try:
        # Get JSON data from AlertManager
        alert_data = request.get_json()
        
        if not alert_data:
            print("No JSON data received")
            return jsonify({"error": "No JSON data"}), 400
        
        print(f"Received alert data: {json.dumps(alert_data, indent=2)}")
        
        # Convert to Discord format
        discord_message = format_discord_message(alert_data)
        
        if not discord_message:
            print("No valid alert data to process")
            return jsonify({"error": "No valid alerts"}), 400
        
        # Send to Discord
        response = requests.post(
            DISCORD_WEBHOOK_URL,
            json=discord_message,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 204:
            print("Successfully sent message to Discord")
            return jsonify({"status": "success"}), 200
        else:
            print(f"Discord API error: {response.status_code} - {response.text}")
            return jsonify({"error": "Discord API error"}), 500
            
    except Exception as e:
        print(f"Error processing webhook: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    print("Starting Discord Webhook Converter...")
    print(f"Discord Webhook URL: {DISCORD_WEBHOOK_URL}")
    app.run(host='0.0.0.0', port=5001, debug=True)
