
## CI285 Calculator API documentation

API for performing 4 basic operations of calculator: addition, subtraction, multiplication, division. Each operation is performed 
in decimal system and requires only two operands. In addition, all URIs has the following general strucutre:

**GET /:operations/:sign/:operand/:sign/:operand**

- **GET** - request method. `GET` primary is used to retrieve information of the resource, but in this case it doesn't exist yet, because any requested calculation will be done after request. But in the future we me implement a cache where most common calculations will be stored. In that case `GET` would make perfect sense.

- **/:operations** - corresponds to addition, subtraction, multiplication and division. At the moment, API supports only those four operations, thus there are only four paths **/additions**, **/subtractions**, **/multiplications** and **/divisions**. Note, that in URI a noun is used instead of verb. While, a verb like _add_ would make better sense, it wouldn't comply with RESTful standards, where URI identifies a resource. "What kind of resource is _/add_ ?" _/additions_, on the other hand, sounds much better. And, like I sad, we may actually have a database or a table, or a map with an actual additions.

- **/:sign/:operand/:sign/:operand** - represents two integers for an operation. At the moment, all operations are bi-operations, thus they epect two operands. 
  - **/:sign** - indicates sign of the integer, and can have only two possible paths: **/positives** and **/negatives**
  - **/:operand/** - a number consisting of only digits. Requirements, didn't specify that the system should support rational or irrational numbers, thus a request which contains any number with at least one non-digit character will be responded with an error. 

In normal situations, the system will respond with status code 200 and JSON content. For example, 
a response for GET request with an URI of

**/additions/negatives/4898/positives/7458** will have content of

  ```json
  {"result": 2560}
  ```
In exceptional situations, the system will respond with an error code and JSON content with appropriate message.

- 400 - bad request. This can happen if 
  - **/:operand** will have at least one non-digit character. E.g, **GET /additions/negatives/48,98/positives/7458** 
  - **/:operand** without a **/:sign**. E.g, **GET /additions/4898/positives/7458** 
  - **/:operations** has less than or more than two operands. E.g, **GET /additions/negatives/4898/**. In later releases, API may allow more operands.
- 404 - not found. This can happen if 
  - **/:operations** or **/:sign** has not been specified or have been mispelled. 
  
