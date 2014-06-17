## POST /api/v1/notifications

Create a notification

+ Request should create a new notification when the notification info is valid (application/json)

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
      "received_at": "2014-06-17T13:38:40.143Z",
      "app_id": 1,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:40.144Z",
      "updated_at": "2014-06-17T13:38:40.144Z",
      "deleted_at": null,
      "viewed_at": null
    }

+ Request should return an error message (application/json)

    {
      "notification": {
        "body": "This is a test."
      }
    }

+ Response 400 (application/json; charset=utf-8)

    {
      "message": {
        "subject": [
          "can't be blank"
        ]
      }
    }

