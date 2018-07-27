```
mutation {
  updateCategory(input:
    {id: "eabb345a-34e4-467e-964a-84e4fb096440",
      category: { name: "Pricing2"}})
  {
    category {
      id
      name
    }
  }
}
# Try to write your query here
```