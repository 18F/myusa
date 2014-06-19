# Group Task


## GET /api/task/:id

Get a single task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-19T16:19:50.000Z",
      "updated_at": "2014-06-19T16:19:50.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-19T16:19:50.000Z",
          "updated_at": "2014-06-19T16:19:50.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-19T16:19:50.000Z",
          "updated_at": "2014-06-19T16:19:50.000Z"
        }
      ]
    }

## PUT /api/task/:id

Update a task

+ Parameters

 + name (optional, string, `Test task`) ...The updated name of the task.
 + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`)... The updated task items that are associated with the task.

+ Request Update a task and task items (application/json)

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
      "completed_at": "2014-06-18T16:19:51.000Z",
      "user_id": 1,
      "created_at": "2014-06-19T16:19:51.000Z",
      "updated_at": "2014-06-19T16:19:51.940Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item one",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-19T16:19:51.000Z",
          "updated_at": "2014-06-19T16:19:51.000Z"
        }
      ]
    }

## POST /api/tasks

Create a new task for the user for this application.

+ Parameters

 + name (required, string, `Test task`) ...The name for the task that is being created.
 + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`) ...A list of task items to be associated with the task.

+ Request Create a new task (application/json)

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
      "created_at": "2014-06-19T16:19:52.924Z",
      "updated_at": "2014-06-19T16:19:52.924Z",
      "app_id": 1,
      "task_items": [

      ]
    }

## GET /api/tasks

List all tasks, and associated attributes, created by the calling application

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-06-19T16:19:54.000Z",
        "updated_at": "2014-06-19T16:19:54.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-06-19T16:19:54.000Z",
            "updated_at": "2014-06-19T16:19:54.000Z"
          }
        ]
      }
    ]

