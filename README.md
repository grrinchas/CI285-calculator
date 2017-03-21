## Users API

API for dealing with users. That is creating new users, updating details, deleting as well as authenticating.

- **POST /users** - registers new user. The POST method is an obvious choice, because no other method would be suitable for this task. For example, we can't use PUT, because it is used to create or replace a resource if it is already exists, which would result of replacing existing users with new ones (see http://stackoverflow.com/questions/630453/put-vs-post-in-rest). 
Example:

```json
{
  "username": "jhonDoe",
  "password": "23#483uA"
}
```
**NOTE** This is not very secure way of doing.

Possible responses:

- 201 - if user have been created successfully.

`Location: http://localhost:3000/users/johnDoe`

Note, that response includes `Location:` in the header which indicates where to find a new resource. But to access it, client must to authenticate itself first.

- 409 - if user with such username already exists.
- 400 - if JSON is not properly formatted
- 404 - otherwise

- **GET /users/:username** - request for users home page. This resource requires user to authenticate itself, before he can access it. Note, that I did not use **/id** instead of **/username**, because an **/id** is less descriptive and less memorable.



## Calculator API

API for performing 4 basic operations of calculator: addition, subtraction, multiplication, division. Each operation is performed 
in decimal system and requires only two operands. In addition, all URIs has the following general strucutre:

**GET /:operations/:operand/:operand**

- **GET** - request method. `GET` primary is used to retrieve information of the resource, but in this case it doesn't exist yet, because any requested calculation will be done after request. But in the future we me implement a cache where most common calculations will be stored. In that case `GET` would make perfect sense.

- **/:operations** - corresponds to addition, subtraction, multiplication and division. At the moment, API supports only those four operations, thus there are only four paths **/additions**, **/subtractions**, **/multiplications** and **/divisions**. Note, that in URI a noun is used instead of verb. While, a verb like _add_ would make better sense, it wouldn't comply with RESTful standards, where URI identifies a resource. "What kind of resource is _/add_ ?" _/additions_, on the other hand, sounds much better. And, like I sad, we may actually have a database or a table, or a map with an actual additions.

- **/:operand/:operand** - represents two integers for an operation. At the moment, all operations are bi-operations, thus they epect two operands. Each operand must consist only of the sequence of digits which can be precede by one of `-` or `+` symbols. 

In normal situations, the system will respond with status code 200 and JSON content. For example, 
a response for GET request with an URI of

**/additions/-4898/7458** will have content of

  ```json
  {"result": "2560"}
  ```
In exceptional situations, the system will respond with an error code and an error page content.

- 404 - not found. This can happen if 
  - **/:operations** has not been specified or have been mispelled. 
  - **/:operand** will have at least one non-digit character. E.g, **GET /additions/48,98/7458** 
  - **/:operations** has less than or more than two operands. E.g, **GET /additions/4898/**.
  
