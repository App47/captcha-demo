import json
import urllib.parse
import urllib.request

VALIDATE_URL = "https://captcha.app47.net/validate"
# The purpose of this handler is to mimic what SFDC would need to do when the form is submitted. It is not meant
# as a complete implementation, but it must check the format of the email and the validity of the token against the
# captcha service.
def lambda_handler(event, context):
    try:
        content_type = event.get("headers", {}).get("content-type", "")
        raw_body = event.get("body", "")
        is_base64_encoded = event.get("isBase64Encoded", False)

        if is_base64_encoded:
            import base64
            raw_body = base64.b64decode(raw_body).decode("utf-8")

        if "application/x-www-form-urlencoded" in content_type:
            form_data = urllib.parse.parse_qs(raw_body)
            email = form_data.get("email", [""])[0]
            token = form_data.get("captcha-token", [""])[0]
        elif "application/json" in content_type:
            json_data = json.loads(raw_body)
            email = json_data.get("email", "")
            token = json_data.get("token", "")
        else:
            raise ValueError("Unsupported content type")

        print(f"Parsed email: {email} and token: {token}")

         # Verify CAPTCHA token by calling your /validate endpoint
        data = json.dumps({"token": token}).encode("utf-8")
        req = urllib.request.Request(
            VALIDATE_URL,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        with urllib.request.urlopen(req) as response:
            result = json.load(response)
            is_valid = result.get("success") is True

        if is_valid and email and "@" in email:
            return {
                "statusCode": 302,
                "headers": {"Location": "https://captcha-demo.app47.net/success.html"}
            }
        else:
            return {
                        "statusCode": 302,
                        "headers": {"Location": "https://captcha-demo.app47.net/error.html"}
                    }

    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return {
            "statusCode": 302,
            "headers": {"Location": "https://captcha-demo.app47.net/error.html"}
        }
