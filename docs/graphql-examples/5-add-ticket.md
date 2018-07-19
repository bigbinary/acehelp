## Create Ticket

To create ticket through GraphQL visit

`http://localhost:3000/graphql/playground`

After you visit URL GraphQL playground will be loaded for you.

Let add our mutation

```
mutation createTicket {
  addTicket(input: {
    email: "sudeep@bigbinary.com",
    name: "Sudeep",
    message: "This is Ticket Message"
  }) {
    ticket {
      id
      name
    }
  }
}
```

Let execute above mutation, after successful execution you will see similar response as mentioned below.

```
{
  "data": {
    "addTicket": {
      "ticket": {
        "id": "3",
        "name": "Sudeep"
      }
    }
  }
}
```

But above mutation declaration is not up to enterprise standard. Every time, when you have to create a ticket with different data you will have to go and edit mutation which is not good. What if we could pass variables to mutations.

Let's change mutation to accept a variable with input parameters.

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

So now as we have altered our mutation to accept input variables. If you try to execute above mutation you will end up getting an error. This is because we haven't passed a variable until now. Let's go and pass a variable.

Open `Query Variables` section which is located at the bottom left corner of the playground. This is the place where we will declare inputs for our mutation.

```
{
  "input": {
    "email": "sudeep@bigbinary.com",
    "name": "Sudeep",
    "message": "this is ticket message"
  }
}
```

This is how you will declare inputs to mutations.

Try executing mutation now, is it working?

Let's refactor this more, if we keep the name of key `input` soon we will end up in confusion as there will more inputs for different mutations and this does not sound good.

Let's modify our mutation to solve above problem.

```
mutation($ticket: CreateTicketInput!) {
  addTicket(input: $ticket) {
    ticket {
      id
      name
    }
  }
}
```

Also, let's refactor our query variable to adopt new mutations changes.

```
{
  "ticket": {
    "email": "sudeep@bigbinary.com",
    "name": "Sudeep",
    "message": "this is ticket message"
  }
}
```

And, you are done!
