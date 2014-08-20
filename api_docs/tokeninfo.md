
# Group Token Info

## GET /api/v1/tokeninfo

Get metadata about the token used to make this request, including
the list of scopes the user has authorized.

+ Response 200 (application/json; charset=utf-8)

  {
    "resource_owner_id": 3879,
    "scopes": [
      "profile.first_name",
      "profile.last_name"
    ],
    "expires_in_seconds": 7200,
    "application": {
      "uid": "b6b334908bed08005ca145fc96ccbd7e4015a0e504d085c77298cf321aaca8f3"
    }
  }
