
# Task API

To use these methods, the user must allow access to the `tasks` scope (your application must also request it from them).

## GET /api/v1/tasks

List all tasks, and associated attributes, created by the calling application

+ Response 200 (application/json; charset=utf-8)

```json
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
```

## POST /api/v1/tasks

Create a new task for the user for this application.

+ Parameters

+ name (required, string, `Test task`) ...The name for the task that is being created.
+ url (optional, string, 'http://18f.gsa.gov') ...an optional URL for the Task. Note you can define URLs for task items too.
+ task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute', :url => 'optional url', :external_id => 'optional ID string' }`) ...A list of task items to be associated with the task. The External ID field is provided for your convenience to more easily map task items to records on your own system. **Note:** there is a separate RESTful API that can be used for individually creating and updating task items associated with tasks.

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
those values will be preserved and will not be overwritten. If a task item is not included in the tasks posted here, it will not be changed at all. To delete a task item, you need to use the RESTful API.

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

## DELETE /api/v1/tasks/:id

Deletes the task associated with the ID and all of its associated task_items. Upon successful deletion, his method returns at HTTP 200 status and the JSON of the task that was deleted.

# Task Items API

Every task can have one or more optional task items associated with it. These task items have the following optional attributes:

* **name**: a name for the task
* **url**: a URL associated with the task
* **external_id**: an optional string that can be used to map this task_item to a records on your own system
* **completed_at**: to indicate when the task was completed
 
Although it is possible to create and update task_items solely within the Tasks API methods, these methods offer a cleaner and more granular interface to modify task items individually. It also is the only way to delete task items. All methods for task items are scoped within the task they belong to, it's impossible to modify a task item without knowing its associated task ID.

## GET /api/v1/tasks/:task_id/task_items

Returns an array of all the task items associated within the task. This is identical to the data within the `task_items` key returned from the `GET /api/v1/tasks/:id` method.

+ Response 200 (application/json; charset=utf-8)

```json
 [  
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
```

## POST /api/v1/tasks/:task_id/task_items

Create a new task item associated with the task. Post a new JSON hash for the item you want to create.

+ Request Create a new task item (application/json)

```json
{
  "task_item": {
    "name": "New Item",
    "external_id": "10020202",
    "url": "http://www.gsa.gov/"
  }
}
```

+ Response 200 (application/json; charset=utf-8)

```json
{
  "id": 5,
  "task_id": 1,
  "name": "New Item",
  "external_id": "10020202",
  "url": "http://www.gsa.gov/",
  "completed_at": null
}
```

## PUT /api/v1/tasks/:task_id/task_items/:id

Update the attributes of a task item. Any attributes not included in the update will not be changed. In addition, there are two different ways that you can mark a task item as completed as part of the PUT:

* Include a `completed_at` field in the PUT body that is a datetime for when the task was completed. Use the ISO 8601 date format only.
* More conveniently, you can just send `"complete": true` and it will set the completion time for the task item automatically.

```json
{
  "complete": true
}
```

+ Response 200 (application/json; charset=utf-8)

```json
{
  "id": 5,
  "task_id": 1,
  "name": "New Item",
  "external_id": "10020202",
  "url": "http://www.gsa.gov/",
  "completed_at": "2015-07-15 21:20:53 -0400"
}
```

## DELETE /api/v1/tasks/:task_id/task_items/:id

Deletes the task item. Upon successful completion, it will return the JSON of the item.

+ Response 200 (application/json; charset=utf-8)

```json
{
  "id": 5,
  "task_id": 1,
  "name": "New Item",
  "external_id": "10020202",
  "url": "http://www.gsa.gov/",
  "completed_at": "2015-07-15 21:20:53 -0400"
}
```