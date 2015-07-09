
# Group Task


## GET /api/v1/tasks

List all tasks, and associated attributes, created by the calling application

+ Response 200 (application/json; charset=utf-8)

  [
    {
      "id": 1,
      "name": "Task #1",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-07-08T17:59:23.000Z",
      "updated_at": "2014-07-08T17:59:23.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item 1 (no url)",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:23.000Z",
          "updated_at": "2014-07-08T17:59:23.000Z"
        }
      ]
    }
  ]

## POST /api/v1/tasks

Create a new task for the user for this application.

+ Parameters

+ name (required, string, `Test task`) ...The name for the task that is being created.
+ url (optional, string, 'http://18f.gsa.gov') ...an optional URL for the Task. Note you can define URLs for task items too.
+ task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute', :url => 'optional url', :external_id => 'optional ID string' }`) ...A list of task items to be associated with the task. The External ID field is provided for your convenience to more easily map task items to records on your own system.

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
      "created_at": "2014-07-08T17:59:22.487Z",
      "updated_at": "2014-07-08T17:59:22.487Z",
      "app_id": 1,
      "task_items": [

      ]
    }

## GET /api/v1/task/:id

Get a single task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-07-08T17:59:23.000Z",
      "updated_at": "2014-07-08T17:59:23.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:23.000Z",
          "updated_at": "2014-07-08T17:59:23.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:23.000Z",
          "updated_at": "2014-07-08T17:59:23.000Z"
        }
      ]
    }


## PUT /api/v1/task/:id

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

Note that if the task or one of its attributes has defined values for fields that are not explicitly included in the PUT request,
those values will be preserved and will not be overwritten.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "url": "This URL was not updated",
      "completed_at": "2014-07-07T17:59:21.000Z",
      "user_id": 1,
      "created_at": "2014-07-08T17:59:21.000Z",
      "updated_at": "2014-07-08T17:59:21.875Z",
      "app_id": 1,
      "task_items": [
      {
        "id": 1,
        "name": "Task item one",
        "url": null,
        "completed_at": null,
        "task_id": 1,
        "created_at": "2014-07-08T17:59:21.000Z",
        "updated_at": "2014-07-08T17:59:21.000Z"
      }
      ]
    }
