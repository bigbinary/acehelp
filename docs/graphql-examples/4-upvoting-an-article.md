
```
mutation {
  upvoteArticle(input: {id:8}) {
    article {
      id
      upvotes_count
    }
  }
}
```