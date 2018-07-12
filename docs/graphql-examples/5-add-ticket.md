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