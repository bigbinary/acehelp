```
mutation createCategory {
  addCategory(input: {
    name: "Pricing"
  }) {
    category {
      id
      name
    }
  }
}
```