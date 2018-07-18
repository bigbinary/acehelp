module Page.Common.Routing exposing (..)

import Page.Url.Create as UrlCreate
import Page.Article.Create as ArticleCreate
import Page.Category.Create as CategoryCreate


type Page
    = CategoryCreate CategoryCreate.Model
    | ArticleCreate ArticleCreate.Model
    | UrlCreate UrlCreate.Model


pageUrl : Page -> String
pageUrl page =
    case page of
        CategoryCreate categoryCreateModel ->
            "/admin/categories/new"

        ArticleCreate articleCreateModel ->
            "/admin/articles/new"

        UrlCreate urlCreateModel ->
            "/admin/urls/new"
