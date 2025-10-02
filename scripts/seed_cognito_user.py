#!/usr/bin/env python3
"""Seed a Cognito user into an existing User Pool.

Usage:
  python scripts/seed_cognito_user.py --user-pool-id <POOL_ID> --username <USERNAME> --email <EMAIL> [--temp-password <Passw0rd!>]

Requires:
  - AWS credentials with cognito-idp:AdminCreateUser permissions
  - boto3 (pip install boto3)

Notes:
  - Creates the user with a temporary password.
  - Marks email as verified and sends invite (unless suppressed).
  - You can also force a password by calling AdminSetUserPassword after create.
"""
import argparse
import sys
import boto3

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--user-pool-id", required=True)
    ap.add_argument("--username", required=True)
    ap.add_argument("--email", required=True)
    ap.add_argument("--temp-password", default="TempPassw0rd!")
    ap.add_argument("--suppress-invite", action="store_true", help="Do not send email invite")
    args = ap.parse_args()

    client = boto3.client("cognito-idp")

    kwargs = {
        "UserPoolId": args.user_pool_id,
        "Username": args.username,
        "TemporaryPassword": args.temp_password,
        "UserAttributes": [
            {"Name": "email", "Value": args.email},
            {"Name": "email_verified", "Value": "true"},
        ],
        "MessageAction": "SUPPRESS" if args.suppress_invite else "RESEND",
    }

    try:
        resp = client.admin_create_user(**kwargs)
        print(f"Created user: {resp['User']['Username']} in pool {args.user_pool_id}")
        print("Temporary password:", args.temp_password)
        print("Next step: First login must set a new password.")
    except client.exceptions.UsernameExistsException:
        print("User already exists.", file=sys.stderr)
        sys.exit(0)

if __name__ == "__main__":
    main()
