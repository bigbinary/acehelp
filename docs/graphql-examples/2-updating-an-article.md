First visit `http://localhost:3000/graphql/playground` and
and get list of articles.

Note the article id of one of the articles.

In the following example replace 8 with the article id.

```
mutation {
  updateArticle(input: {id: 8, article: { title: "Hello", desc: "aa", category_id: 4}}) {
    article {
      id
      title
    }
  }
}
```