# import firebase_admin
# from firebase_admin import messaging, credentials

# To initialize later:
# cred = credentials.Certificate("path/to/serviceAccountKey.json")
# firebase_admin.initialize_app(cred)

def send_push_notification(token, title, body):
    """
    Mock FCM sending since SDK is not configured yet.
    """
    print(f"[FCM Mock] Sending to {token}: {title} - {body}")
    # message = messaging.Message(
    #     notification=messaging.Notification(
    #         title=title,
    #         body=body,
    #     ),
    #     token=token,
    # )
    # response = messaging.send(message)
    # print('Successfully sent message:', response)
