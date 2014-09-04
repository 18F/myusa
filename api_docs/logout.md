
# Group Logout


## GET /users/sign_out?continue=

Log the current user out and end the user's MyUSA session.  With the `continue`
parameter and a valid URL, the user is returned to the URL indicated.  To be
valid, the hostname must be in the same domain (an extension of) the OAuth
application's registered URL.  The OAuth application must also be approved by
the user.

+ Parameters

 + continue (required, url, `http://example.com/page`)

+ Response 302
    + Headers

        Location: http://example.com/page


## GET /users/sign_out

Log the current user out and end the user's MyUSA session.  Without any
parameters, this returns the user to the root page, e.g. http://my.usa.gov/

+ Response 302
