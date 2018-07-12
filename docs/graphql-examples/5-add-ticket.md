```
mutation($input: CreateTicketInput!) {
                addTicket(input: $input) {
                  ticket {
                    id
                    name
                  }
                }
              }
```

In the query variables enter following information.

```
{
  "input": {
    "email": "sudeep@bigbinary.com",
    "name": "Sudeep",
    "message": "this is ticket message"
  }
}
```