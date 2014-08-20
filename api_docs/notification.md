# Group Notification


## POST /api/v1/notifications

This will create a notification for the authenticated user.  The user will be able to view the notification through a user interface, and optionally by email.

+ Parameters

 + subject (required, string, `Test notification`)
 + body (optional, string, `This is a test`)

+ Request Create a new notification (application/json)

    {
      "notification": {
        "subject": "Project MyUSA",
        "body": "This is a test."
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 17,
      "subject": "Project MyUSA",
      "body": "This is a test.",
      "received_at": "2014-07-08T17:59:15.803Z",
      "app_id": 1,
      "user_id": 1,
      "created_at": "2014-07-08T17:59:15.804Z",
      "updated_at": "2014-07-08T17:59:15.804Z",
      "deleted_at": null,
      "viewed_at": null
    }
