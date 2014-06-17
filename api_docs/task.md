# Group Task


## POST /api/v1/tasks

Create a task

+ Request should create a new task for the user (application/json)

    {
      "task": {
        "name": "New Task"
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:23.082Z",
      "updated_at": "2014-06-17T13:38:23.082Z",
      "app_id": 1,
      "task_items": [

      ]
    }

+ Response 400 (application/json; charset=utf-8)

    {
      "message": "can't be blank"
    }

## PUT /api/v1/task/:id

Update a task.

+ Request should no longer be marked as complete when specified (application/json)

    {
      "task": {
        "name": "New Incomplete Task",
        "completed_at": null,
        "task_items_attributes": [
          {
            "id": "2",
            "name": "Task item one"
          }
        ]
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 2,
      "name": "New Incomplete Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:25.000Z",
      "updated_at": "2014-06-17T13:38:26.010Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 2,
          "name": "Task item one",
          "url": null,
          "completed_at": "2014-06-17T13:38:25.000Z",
          "task_id": 2,
          "created_at": "2014-06-17T13:38:25.000Z",
          "updated_at": "2014-06-17T13:38:25.000Z"
        }
      ]
    }

+ Request should return meaningful errors (application/json)

    {
      "task": {
        "name": "New Task",
        "task_items_attributes": [
          {
            "id": "chicken",
            "name": "updated task item name"
          }
        ]
      }
    }

+ Response 422 (application/json; charset=utf-8)

    {
      "message": "Invalid parameters. Check your values and try again."
    }

+ Request should update the task and task items (application/json)

    {
      "task": {
        "name": "New Task",
        "task_items_attributes": [
          {
            "id": "1",
            "name": "Task item one"
          }
        ]
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": "2014-06-16T13:38:28.000Z",
      "user_id": 1,
      "created_at": "2014-06-17T13:38:28.000Z",
      "updated_at": "2014-06-17T13:38:28.231Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item one",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:28.000Z",
          "updated_at": "2014-06-17T13:38:28.000Z"
        }
      ]
    }

## GET /api/v1/tasks

List all tasks.

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-06-17T13:38:32.000Z",
        "updated_at": "2014-06-17T13:38:32.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-06-17T13:38:32.000Z",
            "updated_at": "2014-06-17T13:38:32.000Z"
          }
        ]
      }
    ]

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-06-17T13:38:33.000Z",
        "updated_at": "2014-06-17T13:38:33.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-06-17T13:38:33.000Z",
            "updated_at": "2014-06-17T13:38:33.000Z"
          }
        ]
      }
    ]

## GET /api/v1/task/:id

Retrieve a task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:33.000Z",
      "updated_at": "2014-06-17T13:38:33.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:33.000Z",
          "updated_at": "2014-06-17T13:38:33.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:33.000Z",
          "updated_at": "2014-06-17T13:38:33.000Z"
        }
      ]
    }

