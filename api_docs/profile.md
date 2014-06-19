# Group Profile


## GET /api/profile

Get a list of profiles with all attributes.

+ Response 200 (application/json; charset=utf-8)

    {
      "title": null,
      "first_name": "Joe",
      "middle_name": null,
      "last_name": "Citizen",
      "suffix": null,
      "address": null,
      "address2": null,
      "city": null,
      "state": null,
      "zip": null,
      "gender": null,
      "marital_status": null,
      "is_parent": null,
      "is_student": null,
      "is_veteran": null,
      "is_retired": "0",
      "email": "joe@citizen.org",
      "phone_number": null,
      "mobile_number": null,
      "uid": "93ed4809-c44b-4b0d-9344-3b23517b2c84",
      "id": "93ed4809-c44b-4b0d-9344-3b23517b2c84"
    }

## GET /api/profile schema=>true

Get a list of profiles with attributes limited to those chosen by the app owner during app registration.

+ Parameters

 + schema (required, boolean, `true`)

+ Response 200 (application/json; charset=utf-8)

    {
      "email": "joe@citizen.org",
      "givenName": "Joe",
      "additionalName": null,
      "familyName": "Citizen",
      "homeLocation": {
        "streetAddress": "",
        "addressLocality": null,
        "addressRegion": null,
        "postalCode": null
      },
      "telephone": null,
      "gender": null
    }

